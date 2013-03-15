class WelcomeController < ApplicationController
  skip_authorization_check

  def help
  end

  def feedback
    @feedback = params[:feedback]
    @username = "not-signed-in"
    @registrants = "unknown"
    if signed_in?
      @username = current_user.email
      if current_user.registrants.count > 0
        @registrants = current_user.registrants.first.name
      end
    end
    Notifications.send_feedback(@feedback, @username, @registrants).deliver
    respond_to do |format|
      format.html { redirect_to welcome_help_path, notice: 'Feedback sent successfully.' }
    end
  end
end
