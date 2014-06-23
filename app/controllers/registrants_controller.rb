class RegistrantsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user, only: [:index]
  load_and_authorize_resource except: :new
  load_and_authorize_resource through: :current_user, only: :new
  # NOTE: This isn't working 100%, it fails when a create fails (the breadcrumb is incorrect)

  before_action :set_registrants_breadcrumb
  before_action :set_single_registrant_breadcrumb, only: [:edit, :show, :reg_fee]
  before_action :set_new_registrant_breadcrumb, only: [:new]

  def all_index
    @registrants = Registrant.includes(:user, :contact_detail)
  end

  # GET /registrants
  # GET /registrants.json
  # or
  # GET /users/12/registrants
  def index
    if @user.nil?

      authorize! :manage_all, Registrant
      all_index
      respond_to do |format|
        format.html { render "index_all" }
        format.pdf { render :pdf => "index_all", :template => "registrants/index_all.html.erb", :formats => [:html], :layout => "pdf.html" }
      end
    else
      @my_registrants = @user.registrants.active
      @shared_registrants = @user.accessible_registrants - @my_registrants
      @total_owing = @user.total_owing
      @display_invitation_request = @user.invitations.need_reply.count > 0
      @display_invitation_manage_banner = @user.invitations.permitted.count > 0
      @has_print_waiver = @config.has_print_waiver

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @registrants }
      end
    end
  end

  # GET /registrants/all
  def all
    @registrants = Registrant.includes(:contact_detail).active.order(:bib_number)

    respond_to do |format|
      format.html # all.html.erb
      format.pdf { render :pdf => "all", :formats => [:html], :orientation => 'Landscape', :layout => "pdf.html" }
    end
  end

  # GET /registrants/empty_waiver
  def empty_waiver
    @event_name = @config.long_name
    @event_start_date = @config.start_date.try(:strftime, "%b %-d, %Y")

    respond_to do |format|
      format.html { render action: "waiver", :layout => nil }
      format.pdf { render :pdf => "waiver", :formats => [:html] }
    end
  end

  # GET /registrants/1/waiver
  def waiver
    @registrant = Registrant.find(params[:id])

    @today_date = Date.today.in_time_zone.strftime("%B %-d, %Y")

    @name = @registrant.to_s
    @age = @registrant.age

    contact_detail = @registrant.contact_detail

    @club = contact_detail.club
    @address = contact_detail.address
    @city = contact_detail.city
    @state = contact_detail.state
    @zip = contact_detail.zip
    @country= contact_detail.country_residence
    @phone = contact_detail.phone
    @mobile = contact_detail.mobile
    @email = contact_detail.email
     # if no e-mail specified, use the user email?
    @user_email = current_user.email
    @emergency_name = contact_detail.emergency_name
    @emergency_primary_phone = contact_detail.emergency_primary_phone
    @emergency_other_phone = contact_detail.emergency_other_phone

    empty_waiver # load and display waiver
  end

  # GET /registrants/1
  # GET /registrants/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registrant }
      format.pdf { render_common_pdf("show", "Landscape") }
    end
  end



  # GET /registrants/new
  # GET /registrants/new.json
  def new
    @registrant.competitor = get_competitor_value
    @registrant.build_contact_detail
    load_online_waiver
    load_categories
    load_other_reg

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registrant }
    end
  end

  # GET /registrants/1/edit
  def edit
    add_breadcrumb "Edit", edit_registrant_path(@registrant)
    load_categories
    load_online_waiver
  end

  # POST /registrants
  # POST /registrants.json
  def create
    @registrant.user = current_user

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to registrant_registrant_expense_items_path(@registrant), notice: 'Registrant was successfully created.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @user = current_user
        add_breadcrumb "New"
        load_categories
        load_online_waiver
        format.html { render action: "new" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registrants/1
  # PUT /registrants/1.json
  def update

    respond_to do |format|
      if @registrant.update_attributes(registrant_update_params)
        format.html { redirect_to registrant_registrant_expense_items_path(@registrant), notice: 'Registrant was successfully updated.' }
        format.json { head :no_content }
      else
        edit
        format.html { render action: "edit" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrants/1
  # DELETE /registrants/1.json
  def destroy
    @registrant.deleted = true

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to registrants_url, notice: 'Registrant deleted' }
        format.json { head :no_content }
      else
        edit
        format.html { render action: "edit" }
        format.json { render json: @registrant }
      end
    end
  end

  private

  # determine whether to show the competitor or non-competitor page
  def get_competitor_value
    if params[:non_competitor].nil?
      true
    else
      ! (params[:non_competitor] == "true")
    end
  end

  def set_registrants_breadcrumb
    if @registrant
      @user = @registrant.user
    end
    if @user == current_user
      add_breadcrumb "My Registrants", user_registrants_path(current_user)
    else
     add_breadcrumb "Registrants", registrants_path
    end
  end

  def set_single_registrant_breadcrumb
    add_registrant_breadcrumb(@registrant)
  end

  def set_new_registrant_breadcrumb
    add_breadcrumb "New", new_registrant_path
  end

  def set_reg_fee_breadcrumb
    add_breadcrumb "Set Reg Fee"
  end

  def set_email_breadcrumb
    add_breadcrumb "Send Emails"
  end

  def load_categories
    if @registrant.competitor
      @categories = Category.includes(:translations, :events => :event_choices)
    end
  end

  def load_other_reg
    unless current_user.registrants.empty?
      @other_registrant = current_user.registrants.active.first
    end
  end

  def load_online_waiver
    @has_online_waiver = @config.has_online_waiver
  end

  def attributes
    [ :first_name, :gender, :last_name, :middle_initial, :birthday, :competitor, :volunteer,
      :online_waiver_signature,
      :registrant_choices_attributes => [:event_choice_id, :value, :id],
      :registrant_event_sign_ups_attributes => [:event_category_id, :signed_up, :event_id, :id],
      :registrant_expense_items_attributes => [:expense_item_id, :details],
      :contact_detail_attributes => [:email,
        :address, :city, :country_residence, :country_representing,
        :mobile, :phone, :state, :zip, :club, :club_contact, :usa_member_number,
        :emergency_name, :emergency_relationship, :emergency_attending, :emergency_primary_phone, :emergency_other_phone,
        :responsible_adult_name, :responsible_adult_phone]
    ]
  end

  # don't allow a registrant to be changed from competitor to non-competitor (or vise-versa)
  def registrant_update_params
    attrs = attributes
    attrs.delete(:competitor)
    params.require(:registrant).permit(attrs)
  end

  def registrant_params
    params.require(:registrant).permit(attributes)
  end

  public

  def undelete
    @registrant.deleted = false

    respond_to do |format|
      if @registrant.save(:validate => false) # otherwise the circular validation check for registrant_expense_items fails
        format.html { redirect_to registrants_path, notice: 'Registrant was successfully undeleted.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @registrants = Registrant.all
        format.html { render action: "index_all" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  def bag_labels
    @registrants = Registrant.active.all

    names = []
    @registrants.each do |reg|
      names << "<b>##{reg.bib_number}</b> #{reg.name} \n #{reg.country}"
    end

    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align => :center, :size => 10, :inline_format => true
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  def show_all
    @registrants = Registrant.active.reorder(:last_name, :first_name).includes(:contact_detail, :registrant_expense_items, :registrant_event_sign_ups)

    respond_to do |format|
      format.html # show_all.html.erb
      format.pdf { render :pdf => "show_all", :formats => [:html], :orientation => 'Landscape', :layout => "pdf.html" }
    end
  end

  def email
    set_email_breadcrumb
    @email_form = Email.new
  end

  def send_email
    mass_emailer = MassEmailer.new(params)

    respond_to do |format|
      if mass_emailer.send_emails
        format.html { redirect_to email_registrants_path, notice: 'Email sent successfully.' }
      else
        set_email_breadcrumb
        @email_form = mass_emailer.email_form
        render "email"
      end
    end
  end

  def reg_fee
    set_reg_fee_breadcrumb
  end

  def update_reg_fee
    new_rp = RegistrationPeriod.find(params[:registration_period_id])

    new_reg_item = new_rp.expense_item_for(@registrant.competitor)

    error = false
    # only possible if the registrant is unpaid
    if @registrant.reg_paid?
      error = true
      error_message = "This registrant is already paid"
    end

    respond_to do |format|
      if error || !@registrant.set_registration_item_expense(new_reg_item)
        set_reg_fee_breadcrumb
        format.html { render "reg_fee", alert: error_message  }
      else
        format.html { redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.' }
      end
    end
  end

end
