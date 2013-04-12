class WelcomeController < ApplicationController
  skip_authorization_check

  def help
    @contact_form = ContactForm.new
    @user = current_user
  end

  def feedback
    @contact_form = ContactForm.new(params[:contact_form])

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
end
