class Importers::StatusTranslation::German
  def self.translate(status)
    case status
    when "", nil
      nil
    when "disq"
      "DQ"
    when "abgem"
      "DQ"
    else
      "active"
    end
  end
end
