module BibNumberFinder
  # search for an matching registrant
  class RegistrantMatch
    attr_reader :criteria

    def initialize(registrant, user)
      @criteria = {
        user_id: user.id,
        registrant_type: registrant.registrant_type,
        first_name: registrant.first_name,
        last_name: registrant.last_name,
        birthday: registrant.birthday
      }
    end

    # Search all conventions in this convention series for a
    # registrant which has the same stats as the given registrant
    def matching_registrant
      tenant = Tenant.find_by(subdomain: Apartment::Tenant.current)
      return nil unless tenant.convention_series_member

      tenant.convention_series_member.convention_series.subdomains.each do |subdomain|
        matching_registrant_bib_number = search_for_matching_registrant?(subdomain)
        return matching_registrant_bib_number if matching_registrant_bib_number
      end

      nil
    end

    private

    def search_for_matching_registrant?(subdomain)
      Apartment::Tenant.switch(subdomain) do
        User.find(criteria[:user_id]).registrants.find_by(
          first_name: criteria[:first_name],
          last_name: criteria[:last_name],
          birthday: criteria[:birthday],
          registrant_type: criteria[:registrant_type]
        )&.bib_number
      end
    end
  end
end
