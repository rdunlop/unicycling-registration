class WelcomeController < ApplicationController
  before_action :authenticate_user!, only: [:data_entry_menu]
  before_action :skip_authorization, except: [:data_entry_menu]

  before_action :check_acceptable_format

  def help_translate
  end

  def help
    @user = current_user
  end

  # GET /welcome/usa_membership
  def usa_membership
  end

  # GET /welcome/changelog
  def changelog
  end

  # GET /welcome/confirm
  # The path where users are directed after signing up
  def confirm
  end

  def contact_us
    @contact_form = ContactForm.new
  end

  def feedback
    @contact_form = ContactForm.new(contact_form_params)

    if signed_in?
      @contact_form.update_from_user(current_user)
    end

    if @contact_form.valid? && captcha_valid?
      Notifications.send_feedback(@contact_form.serialize).deliver_later
      respond_to do |format|
        format.html { redirect_to contact_us_welcome_path, notice: 'Feedback sent successfully.' }
      end
    else
      @user = current_user
      render :contact_us
    end
  end

  # This is the "root_path", and redirects the user to different places
  # depending on the configuration of the server.
  def index
    flash.keep
    # if this is the translation domain, put the user on the translation-instructions page
    if translation_domain?
      authenticate_user!
      if user_signed_in?
        redirect_to translations_path
        return
      end
    end

    # if we have a "home" page, show them that
    if Page.exists?(slug: "home")
      redirect_to page_path("home")
    else
      authenticate_user!
      if user_signed_in?
        redirect_to user_registrants_path(current_user)
      end
    end
  end

  def data_entry_menu
    authorize current_user, :view_data_entry_menu?
    @judges = current_user.judges.joins(:competition).merge(Competition.order(scheduled_completion_at: :desc))
    @director_events = Event.with_role(:director, current_user).order(:name)
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
    if ["txt", "png"].include?(params[:format])
      params[:format] = nil
      raise ActiveRecord::RecordNotFound.new
    end
  end

  def contact_form_params
    params.require(:contact_form).permit(:feedback, :email)
  end
end
