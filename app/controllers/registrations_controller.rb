class RegistrationsController < Devise::RegistrationsController
  def create
    if skip_user_creation_confirmation?
      devise_parameter_sanitizer.for(:sign_up) << [:confirmed_at]
      params[:user][:confirmed_at] = DateTime.now
    end

    super
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    welcome_confirm_path
  end
end
