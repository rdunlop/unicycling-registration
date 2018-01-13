module BibNumberFinder
  # search for an unused number
  class FreeNumber
    INITIAL_COMPETITOR = 1
    MAXIMUM_COMPETITOR = 1999

    INITIAL_NON_COMPETITOR = 2001
    MAXIMUM_NON_COMPETITOR = 9999

    attr_reader :competitor_type

    def initialize(competitor_type)
      @competitor_type = competitor_type
    end

    def next_available_bib_number
      tenant = Tenant.find_by(subdomain: Apartment::Tenant.current)
      if tenant.convention_series_member
        range.each do |number|
          if tenant.convention_series_member.convention_series.subdomains.all? { |subdomain| no_registrant?(subdomain, number) }
            return number
          end
        end
      else
        range.each do |number|
          return number if Registrant.where(bib_number: number).none?
        end
      end
    end

    def range
      case competitor_type
      when "competitor"
        (INITIAL_COMPETITOR..MAXIMUM_COMPETITOR)
      when "noncompetitor", "spectator"
        (INITIAL_NON_COMPETITOR..MAXIMUM_NON_COMPETITOR)
      end
    end

    private

    def no_registrant?(subdomain, number)
      Apartment::Tenant.switch(subdomain) do
        Registrant.where(bib_number: number).none?
      end
    end
  end
end
