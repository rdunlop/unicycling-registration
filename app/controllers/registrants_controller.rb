class RegistrantsController < ApplicationController
  before_action :authenticate_user!, except: [:results]
  before_action :load_user, only: [:index]
  before_action :load_registrant_by_bib_number, only: [:show, :results, :destroy, :waiver]
  before_action :authorize_registrant, only: [:show, :destroy, :waiver]
  before_action :authorize_logged_in, only: [:all, :empty_waiver, :subregion_options]
  before_action :skip_authorization, only: [:results]

  before_action :set_registrants_breadcrumb
  before_action :set_single_registrant_breadcrumb, only: [:show]

  # GET /users/12/registrants
  def index
    authorize @user, :registrants?
    @my_registrants = @user.registrants.active_or_incomplete
    @shared_registrants = @user.accessible_registrants - @my_registrants
    @total_owing = @user.total_owing
    @has_print_waiver = @config.has_print_waiver
    @registrant = Registrant.new(user: @user)

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
      format.html { render action: "waiver", layout: "pdf.html" }
      format.pdf { render pdf: "waiver", formats: [:html], layout: "pdf.html" }
    end
  end

  # GET /registrants/1/waiver
  def waiver
    @today_date = Date.today.in_time_zone.strftime("%B %-d, %Y")

    @name = @registrant.to_s
    @age = @registrant.age

    contact_detail = @registrant.contact_detail

    @club = contact_detail.club
    @address = contact_detail.address
    @city = contact_detail.city
    @state = contact_detail.state
    @zip = contact_detail.zip
    @country = contact_detail.country_residence
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
      format.html
      format.json { render json: @registrant }
      format.pdf { render_common_pdf("show", "Portrait") }
    end
  end

  # GET /registrants/1/results
  def results
    @results = @registrant.results.awarded.includes(competitor: [:members, competition: :age_group_type]).select(&:use_for_awards?)
    respond_to do |format|
      format.html
    end
  end

  # DELETE /registrants/1
  # DELETE /registrants/1.json
  def destroy
    @registrant.deleted = true

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to root_path, notice: 'Registrant deleted' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path, alert: "Error deleting registrant" }
      end
    end
  end

  def subregion_options
    render partial: 'subregion_select', locals: {from_object: false}
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_registrant_by_bib_number
    @registrant = Registrant.find_by(bib_number: params[:id])
  end

  def authorize_registrant
    authorize @registrant
  end

  def authorize_logged_in
    authorize current_user, :logged_in?
  end

  def set_registrants_breadcrumb
    add_breadcrumb t("my_registrants", scope: "breadcrumbs"), user_registrants_path(current_user) if current_user
  end

  def set_single_registrant_breadcrumb
    add_registrant_breadcrumb(@registrant)
  end
end
