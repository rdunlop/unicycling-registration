class RegistrationsController < Devise::RegistrationsController
  def create
    if skip_user_creation_confirmation?
      devise_parameter_sanitizer.permit(:sign_up, keys: [:confirmed_at])
      params[:user][:confirmed_at] = DateTime.now
    end

    super
  end

  protected

  def after_inactive_sign_up_path_for(_resource)
    confirm_welcome_path
  end
end
