class RegistrationsController < Devise::RegistrationsController

  def create
    # XXX Note: this still sends the confirmation e-mail, even though it's
    #      not valid.
    super do |resource|
      resource.skip_confirmation! if skip_user_creation_confirmation?
    end
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    welcome_confirm_path
  end
end
