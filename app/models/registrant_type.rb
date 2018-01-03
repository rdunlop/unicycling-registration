module RegistrantType
  TYPES = ['competitor', 'noncompetitor', 'spectator'].freeze

  def self.for(registrant_type)
    case registrant_type
    when 'competitor'
      RegistrantType::Competitor.new
    when 'noncompetitor'
      RegistrantType::Noncompetitor.new
    else
      RegistrantType::Spectator.new
    end
  end
end
