# This is a point-of-indirection to allow for the system
# to handle either Registrant, or ImportedRegistrant records
class AvailableRegistrants

  def self.type
    if EventConfiguration.singleton.imported_registrants?
      "ImportedRegistrant"
    else
      "Registrant"
    end
  end
end
