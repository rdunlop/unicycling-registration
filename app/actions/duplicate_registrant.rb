class DuplicateRegistrant
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  # create a competitor based on the registrant
  def to_competitor
    duplicate("competitor")
  end

  # create a noncompetitor based on the registrant
  def to_noncompetitor
    duplicate("noncompetitor")
  end

  private

  def duplicate(registrant_type)
    Registrant.transaction do
      new_registrant = registrant.dup
      new_registrant.contact_detail = registrant.contact_detail.dup if registrant.contact_detail.present?
      new_registrant.bib_number = nil
      new_registrant.registrant_type = registrant_type
      new_registrant.access_code = nil
      new_registrant.status = "base_details"
      new_registrant.save
    end
  end
end
