module CompetitorAutoCreation
  extend ActiveSupport::Concern

  included do
    attr_accessor :registrant_id
    before_validation :create_competitor_on_demand, on: :create
  end

  # allows saving a lane assignment by registrant_id, and auto-creating the competitor
  def create_competitor_on_demand
    if registrant_id && !competitor
      reg = Registrant.find(registrant_id)

      # does a competitor exist with this bib_number
      self.competitor = reg.competitors.where(competition: competition).first

      if !competitor && EventConfiguration.singleton.can_create_competitors_at_lane_assignment
        # create a competitor if necessary
        self.competitor = competition.create_competitor_from_registrants([reg], nil)
      end
    end
  end
end
