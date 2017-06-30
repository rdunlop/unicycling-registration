# == Schema Information
#
# Table name: public.users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  guest                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  include ApplicationHelper
  rolify after_add: :touch_for_role, after_remove: :touch_for_role

  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :confirmable

  default_scope { order(:email) }

  has_paper_trail meta: {user_id: :id }

  has_many :registrants, -> { includes %i[registrant_expense_items payment_details] }

  has_many :additional_registrant_accesses, dependent: :destroy
  has_many :invitations, through: :registrants, class_name: "AdditionalRegistrantAccess", source: :additional_registrant_accesses

  has_many :judges

  has_many :payments
  has_many :refunds

  has_many :import_results
  has_many :award_labels
  has_many :songs
  has_many :user_conventions

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }
  scope :all_with_registrants, -> { where('users.id IN (SELECT DISTINCT(user_id) FROM registrants)') }
  scope :this_tenant, -> { joins(:user_conventions).merge(UserConvention.where(subdomain: Apartment::Tenant.current)) }

  def touch_for_role(_role)
    touch
  end

  # Cause devise mail to be sent asynchronously
  # https://github.com/plataformatec/devise#activejob-integration
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # get all users who have registrants with unpaid fees
  def self.unpaid_reg_fees
    registrants = Registrant.active.includes(:user).reject(&:reg_paid?)
    registrants.map(&:user).flatten.uniq
  end

  def self.paid_reg_fees
    User.this_tenant.confirmed.all_with_registrants - User.this_tenant.unpaid_reg_fees
  end

  # NOTE: When adding roles Please be sure to add a description in the permissions/index.en.yml
  def self.roles
    # these should be sorted in order of least-priviledge -> Most priviledge
    %i[late_registrant export_payment_lists music_dj awards_admin event_planner translator
       membership_admin competition_admin payment_admin convention_admin super_admin]
  end

  # Public: List of roles available for easy-switching on the staging server
  def self.staging_server_roles
    roles - [:super_admin]
  end

  # List which roles each roles can add to other users
  def self.role_transfer_permissions
    {
      super_admin: [*roles],
      convention_admin: %i[convention_admin payment_admin event_planner music_dj membership_admin export_payment_lists competition_admin],
      competition_admin: %i[competition_admin awards_admin],
      director: [],
      payment_admin: %i[payment_admin late_registrant export_payment_lists],
      event_planner: [:event_planner],
      music_dj: [:music_dj]
    }
  end

  # Which roles are currently allowed to be changed through test-mode
  def self.changable_user_roles
    if Rails.env.stage?
      User.staging_server_roles
    else
      User.roles
    end
  end

  def roles_accessible
    roles.map(&:name).each_with_object([]) do |role, array|
      new_roles = self.class.role_transfer_permissions[role.to_sym]
      array << new_roles if new_roles.present?
    end.flatten.uniq
  end

  # Public: A list of all possible data-entry roles, what is used on each
  # competition is dependent upon the type of competition
  # NOTE: When adding a role here, please be sure to also add a description to the volunteers.manage_volunteer_type.en.yml
  POSSIBLE_DATA_VOLUNTEERS = %i[race_official data_recording_volunteer track_data_importer].freeze

  def self.data_entry_volunteer
    with_role(:data_entry_volunteer).reorder(:name)
  end

  def to_s
    name.presence || email
  end

  def to_s_with_email
    if name.present?
      "#{name} (#{email})"
    else
      email
    end
  end

  #   def additional_editable_registrants
  #     Registrant.active_or_incomplete.joins(:additional_registrant_accesses).merge(additional_registrant_accesses.full_access)
  #   end

  #   def additional_accessible_registrants
  #     Registrant.active_or_incomplete.joins(:additional_registrant_accesses).merge(additional_registrant_accesses.permitted)
  #   end

  def editable_registrants
    (additional_registrant_accesses.full_access.map(&:registrant) + registrants).reject(&:deleted?)
  end

  def accessible_registrants
    (additional_registrant_accesses.permitted.map(&:registrant) + registrants).reject(&:deleted?)
  end

  def total_owing
    accessible_registrants.inject(0.to_money){|memo, reg| memo + reg.amount_owing }
  end

  # Internal: Prevent confirmation from being required for staging
  # server users
  # This overrides the devise:confirmable method to ensure no users require confirmation
  def confirmation_required?
    !Rails.env.stage?
  end

  # Allow user to sign in with a legacy_password
  def valid_password?(password)
    return true if super(password)

    user_conventions.where(subdomain: Apartment::Tenant.current).any? do |user_convention|
      password_match = Devise::Encryptor.compare(self.class, user_convention.legacy_encrypted_password, password)
      Notifications.old_password_used(self, Apartment::Tenant.current).deliver_later if password_match
      false # Always Disallow using older passwords
    end
  end
end
