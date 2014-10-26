class RegistrantsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user, only: [:index]
  load_resource find_by: :bib_number, except: :new
  authorize_resource except: :new
  load_and_authorize_resource through: :current_user, only: :new
  # NOTE: This isn't working 100%, it fails when a create fails (the breadcrumb is incorrect)

  before_action :set_registrants_breadcrumb
  before_action :set_single_registrant_breadcrumb, only: [:edit, :show, :reg_fee]
  before_action :set_new_registrant_breadcrumb, only: [:new]

  # GET /registrants/manage_all
  def manage_all
    @registrants = Registrant.includes(:user, :contact_detail)
    respond_to do |format|
      format.html { render "manage_all" }
      format.pdf { render :pdf => "manage_all", :template => "registrants/manage_all.html.haml", :formats => [:html], :layout => "pdf.html" }
    end
  end

  # post /registrants/manage_one
  def manage_one
  end

  # post /registrant/choose_one
  def choose_one
    if params[:registrant_id].blank?
      flash[:error] = "Choose a Registrant"
      redirect_to manage_one_registrants_path
    else
      registrant = Registrant.find(params[:registrant_id])
      if params[:summary] == "1"
        redirect_to registrant_path(registrant)
      else
        redirect_to edit_registrant_path(registrant)
      end
    end
  end

  # GET /users/12/registrants
  def index
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

  # GET /registrants/all
  def all
    @registrants = Registrant.includes(:contact_detail).active.order(:bib_number)

    respond_to do |format|
      format.html # all.html.erb
      format.pdf { render_common_pdf  "all",  'Landscape' }
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
    @registrant = Registrant.find_by(bib_number: params[:id])

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

  # GET /registrants/1/results
  def results
    @overall_results = @registrant.results.overall
    @age_group_results = @registrant.results.age_group
    respond_to do |format|
      format.html {}
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
        format.html { redirect_to manage_all_registrants_path, notice: 'Registrant deleted' }
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
     add_breadcrumb "Manage Registrants", manage_one_registrants_path
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
      :online_waiver_signature, :wheel_size_id,
      :volunteer_opportunity_ids => [],
      :registrant_choices_attributes => [:event_choice_id, :value, :id],
      :registrant_event_sign_ups_attributes => [:event_category_id, :signed_up, :event_id, :id],
      :contact_detail_attributes => [:id, :email,
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
    clear_events_data!(clear_artistic_data!(params.require(:registrant).permit(attrs)))
  end

  def registrant_params
    clear_events_data!(clear_artistic_data!(params.require(:registrant).permit(attributes)))
  end

  def clear_artistic_data!(original_params)
    # XXX Only do this if I'm not an admin-level person
    return original_params if can? :create_artistic, Registrant
    artistic_event_ids = Event.artistic.map(&:id)
    return original_params unless original_params['registrant_event_sign_ups_attributes']
    original_params['registrant_event_sign_ups_attributes'].each do |key,value|
      if artistic_event_ids.include? value['event_id'].to_i
        flash[:alert] = "Modification of Artistic Events is disabled"
        original_params['registrant_event_sign_ups_attributes'].delete(key)
      end
    end
    original_params
  end

  def registrant_is_already_signed_up(reg, event_id)
    return true if reg.nil? || reg.new_record?
    return reg.registrant_event_sign_ups.where(event_id: event_id).first.try(:signed_up?)
  end

  def clear_events_data!(original_params)
    return original_params if can? :add_events, Registrant
    return original_params unless original_params['registrant_event_sign_ups_attributes']
    original_params['registrant_event_sign_ups_attributes'].each do |key,value|
      event_id = value['event_id'].to_i
      signed_up = value['signed_up'] == "1"
      if !registrant_is_already_signed_up(@registrant, event_id) && signed_up
        flash[:alert] = "Addition of Events is disabled. #{Event.find(event_id)}"
        original_params['registrant_event_sign_ups_attributes'].delete(key)
      end
    end
    original_params
  end

  public

  def undelete
    @registrant.deleted = false

    respond_to do |format|
      if @registrant.save(:validate => false) # otherwise the circular validation check for registrant_expense_items fails
        format.html { redirect_to manage_all_registrants_path, notice: 'Registrant was successfully undeleted.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @registrants = Registrant.all
        format.html { render action: "manage_all" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  def bag_labels
    @registrants = Registrant.includes(:contact_detail).reorder(:sorted_last_name, :first_name).active.all

    names = []
    @registrants.each do |reg|
      names << "\n <b>##{reg.bib_number}</b> #{reg.last_name}, #{reg.first_name} \n #{reg.country}"
    end

    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align => :center, :size => 12, :inline_format => true
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  def show_all
    @registrants = Registrant.active.reorder(:sorted_last_name, :first_name).includes(:contact_detail, :registrant_expense_items, :registrant_event_sign_ups)

    if params[:offset]
      max = params[:max]
      offset = params[:offset]
      @registrants = @registrants.limit(max).offset(offset)
    end

    respond_to do |format|
      format.html # show_all.html.erb
      format.pdf { render_common_pdf  "show_all",  'Landscape' }
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
