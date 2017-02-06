# Migrate users from a single tenant to the GlobalUser table
class GlobalUserMigrator
  attr_accessor :tenant_name
  def initialize(tenant_name)
    @tenant_name = tenant_name
  end

  class User < ApplicationRecord
    # when Apartment::excluded_models is set, this is changed, so we overwrite
    # it with the value which causes this to be forced to be tenant-schema.
    self.table_name = "users"

    # Resolve AssociationTypeMismatch
    def is_a?(klass)
      klass == ::User
    end
  end

  class GlobalUser < ApplicationRecord
    self.table_name = "public.users"
  end

  class UserConvention < ApplicationRecord
    self.table_name = "public.user_conventions"
  end

  # find the maxiumum User id from all tenants
  def self.maximum_user_id
    maximum = 0
    Tenant.all.each do |tenant|
      Apartment::Tenant.switch(tenant.subdomain) do
        tenant_max = User.maximum(:id)
        next if tenant_max.nil?
        if tenant_max > maximum
          maximum = tenant_max
        end
      end
    end
    maximum
  end

  # Set the next ID number for the global User table
  def self.set_global_start_user_id(start_id) # rubocop:disable Style/AccessorMethodName
    GlobalUser.connection.execute("SELECT setval('#{GlobalUser.sequence_name}', #{start_id});")
  end

  def update_global_users
    # Notes:
    # Apartment doesn't allow changing the excluded models without restarting the server:
    # it sets the Class-level table_name to the "Public.users"
    raise "User model mis-configured" if User.table_name == "Public.users" || User.table_name != "users"
    raise "GlobalUser model mis-configured" if GlobalUser.table_name != "public.users"

    # GlobalUser/User models
    # for this tenant
    Apartment::Tenant.switch(tenant_name) do
      # go through each User record
      User.find_each do |user|
        global_user = find_or_create_global_user(user)
        update_global_user_attributes(global_user, user)

        # create a new user_conventions record
        UserConvention.create!(
          user_id: global_user.id,
          legacy_user_id: user.id,
          legacy_encrypted_password: user.encrypted_password,
          subdomain: tenant_name)
      end
    end
  end

  def migrate(table:, column:, from:, to:)
    sql = "UPDATE #{table} SET #{column} = #{to} WHERE #{column} = #{from}"
    User.connection.execute(sql)
  end

  def migrate_user_ids
    # Update all records to point to the id of the global_users table
    Apartment::Tenant.switch(tenant_name) do
      UserConvention.where(subdomain: tenant_name).find_each do |user_convention|
        next unless user_convention.legacy_user_id
        migrate(table: "additional_registrant_accesses",  column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "award_labels",                    column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "feedbacks",                       column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "import_results",                  column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "judges",                          column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "payments",                        column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "refunds",                         column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "registrants",                     column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "songs",                           column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "two_attempt_entries",             column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "users_roles",                     column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "versions",                        column: "user_id", from: user_convention.legacy_user_id, to: user_convention.user_id)

        migrate(table: "external_results",                column: "entered_by_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "heat_lane_judge_notes",           column: "entered_by_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "heat_lane_results",               column: "entered_by_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "time_results",                    column: "entered_by_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "feedbacks",                       column: "resolved_by_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        migrate(table: "mass_emails",                     column: "sent_by_id", from: user_convention.legacy_user_id, to: user_convention.user_id)
        sql = "UPDATE versions SET whodunnit = '#{user_convention.user_id}' WHERE whodunnit = '#{user_convention.legacy_user_id}'"
        User.connection.execute(sql)

        sql = "UPDATE versions SET item_id = #{user_convention.user_id} WHERE item_id = #{user_convention.legacy_user_id} AND item_type = 'User'"
        User.connection.execute(sql)
      end
    end
  end

  private

  def find_or_create_global_user(user)
    global_user = GlobalUser.find_by(email: user.email)
    # If there is an existing GlobalUser record
    return global_user if global_user.present?

    attributes_without_id = user.attributes.reject{|key, _| key == "id" }
    GlobalUser.create!(attributes_without_id)
  end

  # Return false if user not present or not better than global_user
  # return true if global_user is not set, or user is > global_user
  def user_is_greater(global_user, user, attribute)
    return false if user.send(attribute).nil?
    return true if global_user.send(attribute).nil?

    user.send(attribute) > global_user.send(attribute)
  end

  def user_is_lesser(global_user, user, attribute)
    return false if user.send(attribute).nil?
    return true if global_user.send(attribute).nil?

    user.send(attribute) < global_user.send(attribute)
  end

  def update_global_user_attributes(global_user, user)
    if user_is_greater(global_user, user, :current_sign_in_at)
      global_user.current_sign_in_at = user.current_sign_in_at
      global_user.current_sign_in_ip = user.current_sign_in_ip
    end
    if user_is_greater(global_user, user, :last_sign_in_at)
      global_user.last_sign_in_at = user.last_sign_in_at
      global_user.last_sign_in_ip = user.last_sign_in_ip
      global_user.encrypted_password = user.encrypted_password
    end
    if user.created_at < global_user.created_at
      global_user.created_at = user.created_at
    end
    # Cannot do this, rails overwrites the updated_at on save
    # if user.updated_at > global_user.updated_at
    #   global_user.updated_at = user.updated_at
    # end
    if user_is_greater(global_user, user, :reset_password_sent_at)
      global_user.reset_password_token = user.reset_password_token
      global_user.reset_password_sent_at = user.reset_password_sent_at
    end
    if user_is_greater(global_user, user, :confirmation_sent_at)
      global_user.confirmation_token = user.confirmation_token
      global_user.confirmation_sent_at = user.confirmation_sent_at
    end
    if user_is_greater(global_user, user, :remember_created_at)
      global_user.remember_created_at = user.remember_created_at
    end
    unless global_user.name.present?
      global_user.name = user.name
    end
    global_user.sign_in_count = global_user.sign_in_count.to_i + user.sign_in_count.to_i
    if user_is_lesser(global_user, user, :confirmed_at)
      global_user.confirmed_at = user.confirmed_at
    end

    global_user.save!
  end
end
