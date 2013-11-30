class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]
  skip_authorization_check

  def help
    @contact_form = ContactForm.new
    @user = current_user
  end

  def feedback
    @contact_form = ContactForm.new(contact_form_params)

    if signed_in?
      @contact_form.update_from_user(current_user)
    end

    if @contact_form.valid?
      Notifications.send_feedback(@contact_form).deliver
      respond_to do |format|
        format.html { redirect_to welcome_help_path, notice: 'Feedback sent successfully.' }
      end
    else
      @user = current_user
      render "help"
    end
  end

  # chooses the page to display
  def index
    respond_to do |format|
      if signed_in?
        if current_user.has_role? :judge
          format.html { redirect_to judging_events_path }
        else
          format.html { redirect_to registrants_path }
        end
      else
        format.html { redirect_to registrants_path }
      end
    end
  end

  private
  def contact_form_params
    params.require(:contact_form).permit(:feedback)
  end
end
