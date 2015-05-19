class EmailsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :read, Email
    set_email_breadcrumb
    @email_form = Email.new
  end

  def list
    authorize! :list, Email
    set_email_breadcrumb
    @email_form = Email.new(params[:email])
  end

  def create
    authorize! :create, Email
    mass_emailer = MassEmailer.new(params)

    respond_to do |format|
      if mass_emailer.send_emails
        format.html { redirect_to emails_path, notice: 'Email sent successfully.' }
      else
        set_email_breadcrumb
        @email_form = mass_emailer.email_form
        format.html { render "list" }
      end
    end
  end

  private

  def set_email_breadcrumb
    add_breadcrumb "Send Emails"
  end
end
