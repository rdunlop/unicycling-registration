class EventConfirmationEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_contact
  before_action :load_email, only: %i[edit update send_emails preview]
  before_action :ensure_unsent, only: %i[edit update send_emails]

  def index
    set_email_breadcrumb
    @emails = EventConfirmationEmail.all
  end

  def new
    @email = EventConfirmationEmail.new
  end

  def create
    @email = EventConfirmationEmail.new(event_confirmation_email_params)
    if @email.save
      redirect_to preview_event_confirmation_email_path(@email)
    else
      flash.now[:alert] = "Error creating email"
      render :new
    end
  end

  def edit; end

  def update
    if @email.update(event_confirmation_email_params)
      redirect_to preview_event_confirmation_email_path(@email)
    else
      render :edit
    end
  end

  def send_emails
    if @email.send!(current_user)
      flash[:notice] = "Messages Sent"
    else
      flash[:alert] = "Error sending messages"
    end

    redirect_to event_confirmation_emails_path
  end

  def preview
    @registrant = Registrant.active_or_incomplete.competitor.sample
  end

  private

  def load_email
    @email = EventConfirmationEmail.find(params[:id])
  end

  def ensure_unsent
    if @email.sent?
      flash[:alert] = "Email has already been sent"
      redirect_to :index
    end
  end

  def event_confirmation_email_params
    params.require(:event_confirmation_email).permit(:subject, :body, :reply_to_address)
  end

  def authorize_contact
    authorize current_user, :send_event_confirmation_email?
  end

  def set_email_breadcrumb
    add_breadcrumb "Send Event Confirmation Emails"
  end
end
