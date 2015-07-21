class Registrants::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!

  before_action :load_registrant_by_bib_number, except: [:create]
  before_action :set_steps, except: [:drop_event]
  before_action :setup_wizard, except: [:drop_event]

  before_action :load_categories, only: [:show, :update, :add_events]
  layout "wizard"

  ALL_STEPS = [:add_name, :add_events, :set_wheel_sizes, :add_volunteers, :add_contact_details, :expenses]

  def finish_wizard_path
    if @registrant.events_with_music_allowed.any? && policy(Song.new).create?
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

  # DELETE /registrants/:registrant_id/build/drop_event?event_id=:event_id
  def drop_event
    authorize @registrant, :add_events?
    event = Event.find(params[:event_id])
    @registrant.transaction do
      sign_up = @registrant.registrant_event_sign_ups.find_by(event: event)
      choices = @registrant.registrant_choices.includes(event_choice: :event).select{ |ec| ec.event_choice.event == event}
      sign_up.destroy
      choices.map(&:destroy)
    end
    flash[:notice] = "Successfully dropped #{event}"
    redirect_to registrant_build_path(@registrant.bib_number, :add_events)
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


  def registrant_params
    params.require(:registrant).permit(attributes)
  end

end
