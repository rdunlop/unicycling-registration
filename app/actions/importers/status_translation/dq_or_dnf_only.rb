class Importers::StatusTranslation::DqOrDnfOnly
  def self.translate(status)
    case status
    when "DQ"
      "DQ"
    when "DNF"
      "DNF"
    else
      "active"
    end
  end
end
