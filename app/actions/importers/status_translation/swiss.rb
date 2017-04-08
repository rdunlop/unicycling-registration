class Importers::StatusTranslation::Swiss
  def self.translate(status)
    case status.downcase
    when "gestürzt", "scratched", "nicht am start", "disq. rot", "disq. rot agh", "disqualifiziert", "disq. blau", "nicht im ziel"
      "DQ"
    else
      "active" # New behavior
    end
  end

  def self.dq_description(status)
    case status.downcase
    when "gestürzt"
      "Dismount"
    when "scratched"
      "Restart"
    when "nicht am start"
      "DNS"
    when "disq. rot"
      "False Start"
    when "disq. rot agh"
      "Lane"
    when "disqualifiziert"
      "Disqualified" # New behavior
    when "disq. blau"
      "5m Line"
    when "nicht im ziel"
      "DNF"
    end
  end
end
