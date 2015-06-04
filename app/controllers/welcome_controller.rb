class WelcomeController < ApplicationController
  before_action :authenticate_user!, only: [:index, :data_entry_menu]
  skip_authorization_check only: [:index, :help, :feedback, :confirm]
  authorize_resource class: false, only: [:data_entry_menu]

  before_action :check_acceptable_format

  def help
    @contact_form = ContactForm.new
    @user = current_user
  end

  def feedback
    @contact_form = ContactForm.new(contact_form_params)

    if signed_in?
      @contact_form.update_from_user(current_user)
    end

    if @contact_form.valid? && captcha_valid?
      Notifications.send_feedback(@contact_form.serialize).deliver_later
      respond_to do |format|
        format.html { redirect_to welcome_help_path, notice: 'Feedback sent successfully.' }
      end
    else
      @user = current_user
      render "help"
    end
  end

  def index
    flash.keep
    redirect_to user_registrants_path(current_user)
  end

  def data_entry_menu
    @judges = current_user.judges
    @director_events = Event.with_role(:director, current_user)
  end

  private

  def captcha_valid?
    return true unless recaptcha_required?

    verify_recaptcha
  end

  def recaptcha_required?
    Rails.application.secrets.recaptcha_private_key.present? && !signed_in?
  end
  helper_method :recaptcha_required?

  # This tries to get around the apple-touch-icon.png requests
  #  and the humans.txt requests
  def check_acceptable_format
    if ["txt", "png"].include?(params[:format] )
      params[:format] = nil
      raise ActiveRecord::RecordNotFound.new
    end
  end

  def contact_form_params
    params.require(:contact_form).permit(:feedback, :email)
  end
end
