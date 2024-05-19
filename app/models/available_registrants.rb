# This is a point-of-indirection to allow for the system
# to handle either Registrant, or ImportedRegistrant records
class AvailableRegistrants
  # TODO: This should be extracted into a form helper?
  def self.select_box_options
    if EventConfiguration.singleton.imported_registrants?
      ImportedRegistrant.all.map { |reg| [reg.with_id_to_s, reg.id] }
    else
      Registrant.active.competitor.map { |reg| [reg.with_id_to_s, reg.id] }
    end
  end

  def self.type
    if EventConfiguration.singleton.imported_registrants?
      "ImportedRegistrant"
    else
      "Registrant"
    end
  end

  def self.find_by(bib_number:)
    if EventConfiguration.singleton.imported_registrants?
      ImportedRegistrant.find_by(bib_number: bib_number)
    else
      Registrant.find_by(bib_number: bib_number)
    end
  end
end
