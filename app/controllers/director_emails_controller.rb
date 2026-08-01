class DirectorEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_some_contact

  def new
    @email_form = MassEmail.new(sent_by: current_user)
  end

  def create
    @email_form = MassEmail.new(email_params)
    @email_form.sent_by = current_user
    @email_form.email_addresses = director_email_addresses
    @email_form.email_addresses_description = "Directors"
    @email_form.sent_at = Time.current

    if @email_form.save
      @email_form.send_emails
      redirect_to emails_path, notice: 'Email sent successfully.'
    else
      render :new
    end
  end

  helper_method :directors_count
  def directors_count
    director_email_addresses.count
  end

  private

  def authorize_some_contact
    authorize current_user, :contact_some_registrants?
  end

  def email_params
    params.require(:mass_email).permit(:subject, :body)
  end

  def director_email_addresses
    User.with_role(:director, :any).map(&:email).compact.uniq
  end
end
