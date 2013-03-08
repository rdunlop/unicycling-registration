class WelcomeController < ApplicationController
  skip_authorization_check

  def help
  end

  def feedback
    Notifications.send_feedback(params[:feedback]).deliver
    respond_to do |format|
      format.html { redirect_to welcome_help_path, notice: 'Feedback sent successfully.' }
    end
  end
end
