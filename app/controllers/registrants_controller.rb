class RegistrantsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user, only: [:index]
  load_resource find_by: :bib_number
  authorize_resource

  before_action :set_registrants_breadcrumb
  before_action :set_single_registrant_breadcrumb, only: [:show]

  # GET /users/12/registrants
  def index
    @my_registrants = @user.registrants.active_or_incomplete
    @shared_registrants = @user.accessible_registrants - @my_registrants
    @total_owing = @user.total_owing
    @has_print_waiver = @config.has_print_waiver
    @registrant = Registrant.new

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
    unless @registrant.validated?
      flash[:alert] = "Unable to display Summary of incomplete registrant"
      redirect_to :back
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registrant }
      format.pdf { render_common_pdf("show", "Landscape") }
    end
  end

  # GET /registrants/1/results
  def results
    @results = @registrant.results
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

  def set_registrants_breadcrumb
    add_breadcrumb t("my_registrants", scope: "breadcrumbs"), user_registrants_path(current_user)
  end

  def set_single_registrant_breadcrumb
    add_registrant_breadcrumb(@registrant)
  end

  def attributes
    [:first_name, :gender, :last_name, :middle_initial, :birthday, :registrant_type, :volunteer,
     :online_waiver_signature, :wheel_size_id,
     volunteer_opportunity_ids: [],
     registrant_choices_attributes: [:event_choice_id, :value, :id],
     registrant_event_sign_ups_attributes: [:event_category_id, :signed_up, :event_id, :id],
     contact_detail_attributes: [:id, :email,
                                 :address, :city, :country_residence, :country_representing,
                                 :mobile, :phone, :state_code, :zip, :club, :club_contact, :usa_member_number,
                                 :emergency_name, :emergency_relationship, :emergency_attending, :emergency_primary_phone, :emergency_other_phone,
                                 :responsible_adult_name, :responsible_adult_phone]
    ]
  end

  # don't allow a registrant to be changed from competitor to non-competitor (or vise-versa)
  def registrant_update_params
    attrs = attributes
    attrs.delete(:registrant_type)
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
    original_params['registrant_event_sign_ups_attributes'].each do |key, value|
      if artistic_event_ids.include? value['event_id'].to_i
        flash[:alert] = "Modification of Artistic Events is disabled"
        original_params['registrant_event_sign_ups_attributes'].delete(key)
      end
    end
    original_params
  end

  def registrant_is_already_signed_up(reg, event_id)
    return true if reg.nil? || reg.new_record?
    reg.registrant_event_sign_ups.where(event_id: event_id).first.try(:signed_up?)
  end

  def clear_events_data!(original_params)
    return original_params if can? :add_events, Registrant
    return original_params unless original_params['registrant_event_sign_ups_attributes']
    original_params['registrant_event_sign_ups_attributes'].each do |key, value|
      event_id = value['event_id'].to_i
      signed_up = value['signed_up'] == "1"
      if !registrant_is_already_signed_up(@registrant, event_id) && signed_up
        flash[:alert] = "Addition of Events is disabled. #{Event.find(event_id)}"
        original_params['registrant_event_sign_ups_attributes'].delete(key)
      end
    end
    original_params
  end
end
