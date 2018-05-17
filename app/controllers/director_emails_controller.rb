class DirectorEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_some_contact

  def new
    @email_form = Email.new
  end

  def create
    @email_form = Email.new(params[:email])

    if @email_form.valid?
      mass_email = MassEmail.new
      mass_email.subject = @email_form.subject
      mass_email.body = @email_form.body
      mass_email.email_addresses = director_email_addresses
      mass_email.email_addresses_description = "Directors"
      mass_email.sent_by = current_user
      mass_email.sent_at = Time.current
      if mass_email.save
        mass_email.send_emails
        redirect_to emails_path, notice: 'Email sent successfully.'
      else
        redirect_to emails_path, alert: 'Unable to store Mass Email before sending. No e-mail was sent'
      end
    else
      render :new
    end
  end

  private

  def authorize_some_contact
    authorize current_user, :contact_some_registrants?
  end

  def director_email_addresses
    User.with_role(:director).map(&:email).compact
  end
end
