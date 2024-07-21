# Helps create a user with a throw-away email address
# and an arbitrary password
#
# For use by judges, or other reasons
class GuestUserCreator
  attr_reader :user, :errors

  def initialize; end

  # Create a user who can only access a single registrant
  def create_single_registrant_user
    email = "robin+guest#{Time.now.to_i}#{rand(99)}@dunlopweb.com"
    name = "guest"
    user = User.this_tenant.create(name: name, guest: true, confirmed_at: Time.current, email: email)
    user.save!(validate: false)
    user_convention = user.user_conventions.build(subdomain: Apartment::Tenant.current)
    user_convention.save
    @user = user
  end

  # Create user for use as a judge
  # Return true on success,
  # on error, store errors in 'def errors'
  def create_data_entry_volunteer(name:, password:)
    begin
      email = "robin+guest#{Time.now.to_i}#{rand(99)}@dunlopweb.com"
      user = User.this_tenant.create(name: name, guest: true, confirmed_at: Time.current, email: email)
      user.save!(validate: false)
      user_convention = user.user_conventions.build(subdomain: Apartment::Tenant.current)
      user_convention.save

      user.update!(name: name)
      user.update!(password: password)
      user.add_role(:data_entry_volunteer)
      @user = user
    rescue
      @errors = user.errors.full_messages.join(", ")
      false
    end
  end
end
