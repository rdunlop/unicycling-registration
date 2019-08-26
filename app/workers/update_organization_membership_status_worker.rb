class UpdateOrganizationMembershipStatusWorker
  include Sidekiq::Worker

  # Query the membership API, and update the registrant record with the result
  def perform(registrant_id)
    organization_config = EventConfiguration.singleton.organization_membership_config
    return unless organization_config.automated_checking?

    Rails.logger.debug "#{organization_config.title} membership check for #{registrant_id}"
    registrant = Registrant.find(registrant_id)

    organization_membership = registrant.create_organization_membership_record

    checker = organization_config.automated_checking_class.new(
      first_name: registrant.first_name,
      last_name: registrant.last_name,
      birthdate: registrant.birthday,
      manual_member_number: organization_membership.manual_member_number,
      system_member_number: organization_membership.system_member_number
    )

    if checker.current_member?
      organization_membership.update(
        system_confirmed: true,
        system_member_number: checker.current_system_id,
        system_status: "confirmed"
      )
    else
      organization_membership.update(
        system_confirmed: false,
        system_status: "Not Confirmed"
      )
    end
  rescue JSON::ParserError => e
    raise "Error (#{e}) parsing response from Organization database for #{request}"
  end
end
