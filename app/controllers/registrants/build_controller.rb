class Registrants::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!

  before_action :load_registrant_by_bib_number, except: [:create]
  before_action :set_steps
  before_action :setup_wizard

  before_action :load_categories, only: [:show, :update, :add_events]
  layout "wizard"

  ALL_STEPS = [:add_name, :add_events, :set_wheel_sizes, :add_volunteers, :add_contact_details, :expenses]

  def finish_wizard_path
    if @registrant.has_event_with_music_allowed? && policy(Song.new).create?
      registrant_songs_path(@registrant)
    else
      registrant_path(@registrant)
    end
  end

  # redirect to the first step, or back if no steps are allowed
  def index
    skip_authorization
    if steps.any?
      redirect_to registrant_build_path(@registrant, steps.first)
    else
      flash[:alert] = "Unable to Update any Registrant pages"
      redirect_to :back
    end
  end

  def show
    authorize @registrant, "#{wizard_value(step)}?".to_sym

    case wizard_value(step)
    when :add_name
    when :add_events
      skip_step unless @registrant.competitor
    when :add_volunteers
    end

    render_wizard
  end

  def update
    authorize @registrant, "#{wizard_value(step)}?".to_sym
    case wizard_value(step)
    when :add_name
      @registrant.status = "base_details" if @registrant.status == "blank"
    when :add_events
      @registrant.status = "events" if @registrant.status == "base_details"
    when :add_volunteers
    when :add_contact_details
      @registrant.status = "contact_details" if @registrant.status == "events" || @registrant.status == "base_details"
    end
    @registrant.status = 'active' if step == steps.last

    @registrant.update_attributes(registrant_params)
    render_wizard @registrant
  end

  # create an initial registrant/blank record
  def create
    @registrant = Registrant.new(registrant_params)
    @registrant.user = current_user
    authorize @registrant

    @registrant.status = "base_details"
    if @registrant.save
      # drop into the second step
      set_steps # reset steps to ensure we get the correct set of steps
      redirect_to wizard_path(steps.second, registrant_id: @registrant)
    else
      flash[:alert] = "Unable to create registrant: " + @registrant.errors.full_messages.join(", ")
      redirect_to user_registrants_path(current_user)
    end
  end

  private

  def load_registrant_by_bib_number
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
  end

  # Set the steps to those which are currently accessible to my user
  def set_steps
    if @registrant.nil?
      # when creating a registrant
      self.steps = ALL_STEPS
    else
      self.steps = ALL_STEPS.select { |step| policy(@registrant).send("#{step}?") }
    end
  end

  def registrant_type
    params[:registrant_type]
  end

  def load_categories
    if @registrant.competitor
      @categories = Category.load_for_form
    end
  end

  def attributes
    [:first_name, :gender, :last_name, :middle_initial, :birthday, :registrant_type, :volunteer,
     :online_waiver_signature, :wheel_size_id, :rules_accepted,
     volunteer_opportunity_ids: [],
     registrant_choices_attributes: [:event_choice_id, :value, :id],
     registrant_event_sign_ups_attributes: [:event_category_id, :signed_up, :event_id, :id],
     contact_detail_attributes: [:id, :email,
                                 :birthplace, :italian_fiscal_code,
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
    clear_events_data!(clear_artistic_data!(params.fetch(:registrant, {}).permit(attrs)))
  end

  def registrant_params
    clear_events_data!(clear_artistic_data!(params.fetch(:registrant, {}).permit(attributes)))
  end

  def clear_artistic_data!(original_params)
    # XXX Only do this if I'm not an admin-level person
    return original_params if policy(current_user).add_artistic_events?
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

  # OLD CODE, which used to allow users to drop events, but not add events
  # CURRENTLY disabled, as I don't know whether this is needed
  def clear_events_data!(original_params)
    original_params
    # return original_params if policy(current_user).add_events?
    # return original_params unless original_params['registrant_event_sign_ups_attributes']
    # original_params['registrant_event_sign_ups_attributes'].each do |key, value|
    #   event_id = value['event_id'].to_i
    #   signed_up = value['signed_up'] == "1"
    #   if !registrant_is_already_signed_up(@registrant, event_id) && signed_up
    #     flash[:alert] = "Addition of Events is disabled. #{Event.find(event_id)}"
    #     original_params['registrant_event_sign_ups_attributes'].delete(key)
    #   end
    # end
    # original_params
  end
end
