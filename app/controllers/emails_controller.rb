class EmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_contact
  include ExcelOutputter

  def index
    set_email_breadcrumb
    @email_form = Email.new
  end

  def download
    headers = ["Registrant ID", "First Name", "Last Name", "Email", "Created At"]

    data = []
    Registrant.active_or_incomplete.includes(:contact_detail).each do |registrant|
      data << [
        registrant.bib_number,
        registrant.first_name,
        registrant.last_name,
        registrant.contact_detail.try(:email),
        registrant.created_at.to_s(:short)
      ]
    end

    filename = "#{@config.short_name}_Registrant_Emails_#{Date.today}"

    output_spreadsheet(headers, data, filename)
  end

  def list
    set_email_breadcrumb
    @email_form = Email.new(params[:email])
  end

  def create
    @email_form = Email.new(params[:email])

    respond_to do |format|
      if @email_form.valid?
        mass_emailer = MassEmailer.new(@email_form.subject, @email_form.body, @email_form.filtered_combined_emails)
        mass_emailer.send_emails
        format.html { redirect_to emails_path, notice: 'Email sent successfully.' }
      else
        set_email_breadcrumb
        format.html { render "list" }
      end
    end
  end

  private

  def authorize_contact
    authorize current_user, :contact_registrants?
  end

  def set_email_breadcrumb
    add_breadcrumb "Send Emails"
  end
end
