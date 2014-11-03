class Registrants::BuildController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!
  load_and_authorize_resource :user

  steps :add_name, :add_events, :add_volunteers

  before_action :load_registrant, only: [:show, :update]
  before_action :load_categories, only: [:show, :update, :add_events]

  def show
    render_wizard
  end

  def update
    #params[:registrant][:status] = step.to_s
    #params[:registrant][:status] = 'active' if step == steps.last
    @registrant.update_attributes(registrant_params)
    render_wizard @registrant
  end


  def create
    @registrant = Registrant.create
    redirect_to wizard_path(steps.first, :registrant_id => @registrant.id)
  end

  private

  def load_registrant
    @registrant = Registrant.find(params[:registrant_id])
  end

  def load_categories
    if @registrant.competitor
      @categories = Category.includes(:translations, :events => :event_choices)
    end
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
end
