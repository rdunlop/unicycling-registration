class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:index]
  skip_authorization_check only: [:index, :help, :feedback, :confirm]
  authorize_resource class: false, only: [:judging_menu, :data_entry_menu]

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
        if current_user.roles.any?
          flash.keep
          format.html { redirect_to welcome_data_entry_menu_path }
        else
          flash.keep
          format.html { redirect_to user_registrants_path(current_user) }
        end
        # This tries to get around the apple-touch-icon.png requests
        format.png { return render :nothing => true, :status => 200, :content_type => 'text/html' }
      else
        format.html { redirect_to registrants_path }
      end
    end
  end

  def judging_menu
    @judges = current_user.judges
  end

  def data_entry_menu
    @judges = current_user.judges
  end

  private
  def contact_form_params
    params.require(:contact_form).permit(:feedback, :email)
  end
end
