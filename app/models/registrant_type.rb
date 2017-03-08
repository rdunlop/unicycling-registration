class RegistrantType
  def self.for(registrant_type)
    case registrant_type
    when 'competitor'
      RegistrantType::Competitor.new
    when 'noncompetitor'
      RegistrantType::Noncmpetitor.new
    else
      RegistrantType::Spectator.new
    end
  end
end
