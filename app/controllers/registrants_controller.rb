class RegistrantsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def load_categories
    if @registrant.competitor
      @categories = Category.includes(:events).all
    end
  end

  # GET /registrants
  # GET /registrants.json
  def index
    @registrants = current_user.registrants
    @total_owing = current_user.total_owing

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrants }
    end
  end

  # GET /registrants/all
  def all
    @registrants = Registrant.all
  end

  # GET /registrants/1/waiver
  def waiver
    @registrant = Registrant.find(params[:id])


    @today_date = Date.today.strftime("%B %-d, %Y")

    config = EventConfiguration.first
    unless config.nil?
      @event_name = config.long_name
      @event_start_date = config.start_date.strftime("%b %-d, %Y")
    end

    @name = @registrant.to_s
    @club = @registrant.club
    @registrant_id = @registrant.id
    @age = @registrant.age

    @address = @registrant.address
    @city = @registrant.city
    @state = @registrant.state
    @zip = @registrant.zip
    @country = @registrant.country
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
    @registrant = Registrant.find(params[:id])
    @has_minor = current_user.has_minor?

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registrant }
    end
  end

  # GET /registrants/new
  # GET /registrants/new.json
  def new
    @registrant = Registrant.new
    @registrant.competitor = true
    load_categories

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registrant }
    end
  end

  def new_noncompetitor
    @registrant = Registrant.new
    @registrant.competitor = false

    respond_to do |format|
      format.html { render action: "new" } # new.html.erb
      format.json { render json: @registrant }
    end
  end

  def items
    @registrant = Registrant.find(params[:id])
  end

  def update_items
    @registrant = Registrant.find(params[:id])

    respond_to do |format|
      if @registrant.update_attributes(params[:registrant])
        format.html { redirect_to @registrant, notice: 'Registrant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /registrants/1/edit
  def edit
    @registrant = Registrant.find(params[:id])
    load_categories
  end

  # POST /registrants
  # POST /registrants.json
  def create
    @registrant = Registrant.new(params[:registrant])
    @registrant.user = current_user

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to items_registrant_path(@registrant), notice: 'Registrant was successfully created.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        load_categories
        format.html { render action: "new" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registrants/1
  # PUT /registrants/1.json
  def update
    @registrant = Registrant.find(params[:id])

    respond_to do |format|
      if @registrant.update_attributes(params[:registrant])
        format.html { redirect_to items_registrant_path(@registrant), notice: 'Registrant was successfully updated.' }
        format.json { head :no_content }
      else
        load_categories
        format.html { render action: "edit" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrants/1
  # DELETE /registrants/1.json
  def destroy
    @registrant = Registrant.find(params[:id])
    @registrant.destroy

    respond_to do |format|
      format.html { redirect_to registrants_url }
      format.json { head :no_content }
    end
  end
end
