module CompetitorAutoCreation
  extend ActiveSupport::Concern

  included do
    attr_accessor :registrant_id
    before_validation :create_competitor_on_demand, on: :create
  end

  # allows saving a lane assignment by registrant_id, and auto-creating the competitor
  def create_competitor_on_demand
    if EventConfiguration.singleton.can_create_competitors_at_lane_assignment
      if registrant_id
        reg = Registrant.find(registrant_id)

        # does a competitor exist with this bib_number
        comp = competition.find_competitor_with_bib_number(reg.bib_number)

        # create a competitor if necessary
        comp ||= competition.create_competitor_from_registrants([reg], nil)

        self.competitor = comp
      end
    end
  end
end
