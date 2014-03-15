class RegistrantsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_registrant, :only => [:undelete]
  load_and_authorize_resource

  private

  def find_registrant
    @registrant = Registrant.unscoped.find(params[:id])
  end

  def load_categories
    if @registrant.competitor
      @categories = Category.includes(:events).all
    end
  end

  def load_other_reg
    unless current_user.registrants.empty?
      @other_registrant = current_user.registrants.first
    end
  end

  def load_online_waiver
    @has_online_waiver = EventConfiguration.has_online_waiver
    @online_waiver_text = EventConfiguration.online_waiver_text
  end

  public

  def all_index
    @registrants = Registrant.unscoped.all
  end

  # GET /registrants
  # GET /registrants.json
  # or
  # GET /users/12/registrants
  def index
    if params[:user_id].nil?
      authorize! :manage_all, Registrant
      all_index
      respond_to do |format|
        format.html { render "index_all" }
        format.pdf { render :pdf => "index_all", :template => "registrants/index_all.html.erb", :formats => [:html], :layout => "pdf.html" }
      end
    else
      @my_registrants = current_user.registrants
      @shared_registrants = current_user.accessible_registrants - @my_registrants
      @display_invitation_request = current_user.invitations.need_reply.count > 0
      @display_invitation_manage_banner = current_user.invitations.permitted.count > 0
      @user = current_user
      @has_print_waiver = EventConfiguration.has_print_waiver
      @usa_event = EventConfiguration.usa
      @iuf_event = EventConfiguration.iuf
      load_online_waiver

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @registrants }
      end
    end
  end

  # GET /registrants/all
  def all
    @registrants = Registrant.order(:bib_number)

    respond_to do |format|
      format.html # all.html.erb
      format.pdf { render :pdf => "all", :formats => [:html], :orientation => 'Landscape', :layout => "pdf.html" }
    end
  end

  # GET /registrants/empty_waiver
  def empty_waiver
    config = EventConfiguration.first
    unless config.nil?
      @event_name = config.long_name
      @event_start_date = config.start_date.strftime("%b %-d, %Y")
    end

    respond_to do |format|
      format.html { render action: "waiver", :layout => nil }
      format.pdf { render :pdf => "waiver", :formats => [:html] }
    end
  end

  # GET /registrants/1/waiver
  def waiver
    @registrant = Registrant.find(params[:id])

    @today_date = Date.today.to_time_in_current_zone.strftime("%B %-d, %Y")

    config = EventConfiguration.first
    unless config.nil?
      @event_name = config.long_name
      @event_start_date = config.start_date.strftime("%b %-d, %Y")
    end

    @name = @registrant.to_s
    @club = @registrant.club
    @age = @registrant.age

    @address = @registrant.address
    @city = @registrant.city
    @state = @registrant.state
    @zip = @registrant.zip
    @country= @registrant.country_residence
    @phone = @registrant.phone
    @mobile = @registrant.mobile
    @email = @registrant.email
     # if no e-mail specified, use the user email?
    @user_email = current_user.email
    @emergency_name = @registrant.emergency_name
    @emergency_primary_phone = @registrant.emergency_primary_phone
    @emergency_other_phone = @registrant.emergency_other_phone

    respond_to do |format|
      format.html { render action: "waiver", :layout => nil }
      format.pdf { render :pdf => "waiver", :formats => [:html] }
    end
  end

  # GET /registrants/1
  # GET /registrants/1.json
  def show
    @has_minor = current_user.has_minor?
    @has_print_waiver = EventConfiguration.has_print_waiver
    load_online_waiver
    @usa_event = EventConfiguration.usa
    @iuf_event = EventConfiguration.iuf

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registrant }
      format.pdf { render_common_pdf("show", "Landscape") }
    end
  end

  # determine whether to show the competitor or non-competitor page
  def get_competitor_value
    if params[:non_competitor].nil?
      true
    else
      ! (params[:non_competitor] == "true")
    end
  end

  # GET /registrants/new
  # GET /registrants/new.json
  def new
    @registrant = Registrant.new
    @registrant.competitor = get_competitor_value
    load_online_waiver
    load_categories
    load_other_reg

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registrant }
    end
  end

  def items
    @registrant = Registrant.find(params[:id])
  end

  # GET /registrants/1/edit
  def edit
    load_categories
    load_online_waiver
  end

  # POST /registrants
  # POST /registrants.json
  def create
    @registrant.user = current_user

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to items_registrant_path(@registrant), notice: 'Registrant was successfully created.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
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
        format.html { redirect_to items_registrant_path(@registrant), notice: 'Registrant was successfully updated.' }
        format.json { head :no_content }
      else
        load_categories
        load_online_waiver
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
        format.html { render action: "edit" }
        format.json { render json: @registrant }
      end
    end
  end

  private
  def attributes
    [:address, :birthday, :city, :country_residence, :country_representing, :competitor,
                                       :email, :first_name, :gender, :last_name, :middle_initial, :mobile, :phone, :state, :zip,
                                       :club, :club_contact, :usa_member_number, :volunteer,
                                       :emergency_name, :emergency_relationship, :emergency_attending, :emergency_primary_phone, :emergency_other_phone,
                                       :responsible_adult_name, :responsible_adult_phone,
                                       :online_waiver_signature,
                                       :registrant_choices_attributes => [:event_choice_id, :value, :id],
                                       :registrant_event_sign_ups_attributes => [:event_category_id, :signed_up, :event_id, :id],
                                       :registrant_expense_items_attributes => [:expense_item_id, :details]
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
        @registrants = Registrant.unscoped
        format.html { render action: "index_all" }
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

  def show_all
    @registrants = Registrant.order(:last_name, :first_name).all

    respond_to do |format|
      format.html # show_all.html.erb
      format.pdf { render :pdf => "show_all", :formats => [:html], :orientation => 'Landscape', :layout => "pdf.html" }
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
        format.html { redirect_to email_registrants_path, notice: 'Email sent successfully.' }
      end
    else
      render "email"
    end
  end

  def reg_fee
  end

  def update_reg_fee
    new_rp = RegistrationPeriod.find(params[:registration_period_id])

    if @registrant.competitor
      new_reg_item = new_rp.competitor_expense_item
    else
      new_reg_item = new_rp.noncompetitor_expense_item
    end

    error = false
    # only possible if the registrant is unpaid
    if @registrant.reg_paid?
      error = true
      error_message = "This registrant is already paid"
    else
      curr_rei = @registrant.registration_item
      if curr_rei.nil?
        error = true
        error_message = "Unable to find existing Registration Item"
      else
        curr_rei.expense_item = new_reg_item
        curr_rei.locked = true
      end
    end

    respond_to do |format|
      if error or !curr_rei.save
        format.html { render "reg_fee", alert: error_message  }
      else
        format.html { redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.' }
      end
    end
  end
end
