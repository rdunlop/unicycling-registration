class Devise::CustomRegistrationsController < Devise::RegistrationsController
  include LegacyPasswordClearer

  before_action :check_for_existing_user, only: [:create]

  def create
    if skip_user_creation_confirmation?
      devise_parameter_sanitizer.permit(:sign_up, keys: [:confirmed_at])
      params[:user][:confirmed_at] = DateTime.now
    end

    super
  end

  def update
    super do |resource|
      if resource.errors.empty?
        clear_legacy_passwords(resource)
      end
    end
  end

  protected

  # If a user is trying to sign up, but they already have an account,
  # redirect them to the session-sign-in page
  def check_for_existing_user
    user = User.find_for_authentication(email: params[:user][:email])
    if user.present?
      flash[:alert] = t(".flash_error")
      redirect_to new_user_session_path(user: { email: params[:user][:email]})
    end
  end

  def after_inactive_sign_up_path_for(_resource)
    confirm_welcome_path
  end
end
