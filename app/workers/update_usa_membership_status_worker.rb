class UpdateUsaMembershipStatusWorker
  include Sidekiq::Worker

  # Query the USA membership API, and update the registrant record with the result
  def perform(registrant_id)
    return unless event_is_usa?

    Rails.logger.debug "USA membership check for #{registrant_id}"
    registrant = Registrant.find(registrant_id)

    organization_membership = registrant.create_organization_membership_record

    checker = UsaMembershipChecker.new(
      first_name: registrant.first_name,
      last_name: registrant.last_name,
      birthdate: registrant.birthday,
      usa_member_number: organization_membership.manual_member_number,
      wildapricot_member_number: organization_membership.system_member_number
    )

    if checker.current_member?
      organization_membership.update(
        system_confirmed: true,
        system_member_number: checker.current_wildapricot_id,
        system_status: "confirmed"
      )
    else
      organization_membership.update(
        system_confirmed: true,
        system_status: "Not Confirmed"
      )
    end
  rescue JSON::ParserError => ex
    raise "Error (#{ex}) parsing response from USA database for #{request}"
  end

  def event_is_usa?
    EventConfiguration.singleton.organization_membership_usa?
  end
end
