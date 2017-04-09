class Importers::StatusTranslation::Swiss
  def self.translate(status)
    case status.try(:downcase)
    when "gestürzt", "scratched", "nicht am start", "disq. rot", "disq. rot agh", "disqualifiziert", "disq. blau", "nicht im ziel"
      "DQ"
    when nil
      "DQ"
    else
      "active" # New behavior
    end
  end

  def self.dq_description(status)
    case status.try(:downcase)
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
    when nil
      "No Data"
    end
  end
end
