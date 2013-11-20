class Admin::RegistrantsController < Admin::BaseController
  before_filter :authenticate_user!
  before_filter :find_registrant, :only => [:undelete]
  load_and_authorize_resource

  def index
    @registrants = Registrant.unscoped.all
  end

  def fixing_free
    @registrants = Registrant.all
  end

  def create_free_email
    @email_form = Email.new(params[:email])
    respond_to do |format|
      if Notifications.send_mass_email(@email_form, [@registrant.user.email]).deliver
        format.html { redirect_to registrant_path(@registrant), notice: 'Email sent successfully' }
      else
        format.html { redirect_to registrant_path(@registrant), error: 'Error sending e-mail' }
      end
    end
  end

  def create_free_items
    refund = Refund.new
    refund.user = current_user
    refund.refund_date = Date.today
    refund.note = "Free Item fix"
    registrant_was_valid = @registrant.valid?
    @registrant.paid_details.where({:free => true}).each do |pd|
      rd = refund.refund_details.build
      rd.payment_detail = pd
      rei = @registrant.registrant_expense_items.build
      rei.free = true
      rei.system_managed = false
      rei.details = nil
      rei.expense_item = pd.expense_item
    end

    respond_to do |format|
      if refund.valid? and registrant_was_valid and refund.save and @registrant.save
        format.html { redirect_to registrant_path(@registrant), notice: 'Refund successfully created' }
      else
        format.html { redirect_to registrant_path(@registrant), error: 'Refund FAILED' }
      end
    end
  end

  def find_registrant
    @registrant = Registrant.unscoped.find(params[:id])
  end

  def undelete
    @registrant.deleted = false

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to admin_registrants_path, notice: 'Registrant was successfully undeleted.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @registrants = Registrant.unscoped
        format.html { render action: "index" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  def bag_labels
    @registrants = Registrant.all

    names = []
    @registrants.each do |reg|
      names << "<b>##{reg.bib_number}</b> #{reg.name} \n #{reg.country}"
    end

    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align => :center, :size => 10, :inline_format => true
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  def all_summary
    @registrants = Registrant.order(:last_name, :first_name).all

    respond_to do |format|
      format.html # all_summary.html.erb
      format.pdf { render :pdf => "all_summary", :formats => [:html], :orientation => 'Landscape', :layout => "pdf.html" }
    end
  end

  def email
    @email_form = Email.new
  end

  def send_email
    @email_form = Email.new(params[:email])

    if @email_form.valid?
      set_of_addresses = @email_form.email_addresses
      first_index = 0
      current_set = set_of_addresses.slice(first_index, 30)
      until current_set == [] or current_set.nil?
        Notifications.send_mass_email(@email_form, current_set).deliver
        first_index += 30
        current_set = set_of_addresses.slice(first_index, 30)
      end
      respond_to do |format|
        format.html { redirect_to email_admin_registrants_path, notice: 'Email sent successfully.' }
      end
    else
      render "email"
    end
  end
end
