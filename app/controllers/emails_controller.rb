class EmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_contact
  include ExcelOutputter

  def index
    set_email_breadcrumb
    @email_form = Email.new
    @filters = filters
  end

  def all_sent
    @emails = MassEmail.all
  end

  def sent
    @email = MassEmail.find(params[:id])
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
    if params[:filter_email]
      selected_filter = filters.find{|filter| filter.filter == params[:filter_email][:filter] }
      @filter = selected_filter.new(params[:filter_email][:arguments])
    end
    set_email_breadcrumb
    @email_form = Email.new # (params[:email])
  end

  def create
    @email_form = Email.new(params[:email])

    if @email_form.valid?
      mass_email = MassEmail.new
      mass_email.subject = @email_form.subject
      mass_email.body = @email_form.body
      mass_email.email_addresses = @email_form.filtered_combined_emails
      mass_email.email_addresses_description = @email_form.filter_description
      mass_email.sent_by = current_user
      mass_email.sent_at = DateTime.current
      if mass_email.save
        mass_email.send_emails
        redirect_to emails_path, notice: 'Email sent successfully.'
      else
        redirect_to emails_path, alert: 'Unable to store Mass Email before sending. No e-mail was sent'
      end
    else
      set_email_breadcrumb
      render "list"
    end
  end

  private

  def filters
    [
      EmailFilters::ConfirmedAccounts,
      EmailFilters::Competitions
    ]
  end

  def check_auth(auth_object)
    auth_object = current_user if auth_object.nil?

    if auth_object.is_a?(Array)
      auth_object.each { |auth| check_auth(auth) }
    else
      authorize auth_object, :contact_registrants?
    end
  end

  def authorize_contact
    authorize current_user, :contact_registrants?
  end

  def set_email_breadcrumb
    add_breadcrumb "Send Emails"
  end
end
