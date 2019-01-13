class UpdateUsaMembershipStatusWorker
  include Sidekiq::Worker

  # Query the USA membership API, and update the registrant record with the result
  def perform(registrant_id)
    return if server.blank?
    return unless event_is_usa?

    Rails.logger.debug "USA membership check for #{registrant_id}"
    registrant = Registrant.find(registrant_id)

    contact_detail = registrant.contact_detail

    checker = UsaMembershipChecker.new(registrant.first_name, registrant.last_name, registrant.birthday)

    process_response(contact_detail, checker.current_member?)
  rescue JSON::ParserError => ex
    raise "Error (#{ex}) parsing response from USA database for #{request}"
  end

  # Take the response hash, and update the registrant record
  def process_response(contact_detail, member)
    contact_detail.update(
      organization_membership_system_confirmed: member,
      organization_membership_system_status: member ? "confirmed" : "Not Confirmed"
    )
  end

  def event_end_date
    EventConfiguration.singleton.start_date + 10.days
  end

  def event_is_usa?
    EventConfiguration.singleton.organization_membership_usa?
  end
end
