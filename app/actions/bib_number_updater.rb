class BibNumberUpdater
  # set a user to the new bib number
  def self.update_bib_number(registrant, new_bib_number)
    return false unless valid_new_bib_number(registrant, new_bib_number)
    free_bib_number(new_bib_number)
    registrant.update(bib_number: new_bib_number)
  end

  # Check to see whether a given bib number is valid for the given registrant
  def self.valid_new_bib_number(registrant, new_bib_number)
    max_possible_bib_number = registrant.registrant_type_model.class::MAXIMUM
    min_possible_bib_number = registrant.registrant_type_model.class::INITIAL

    min_possible_bib_number <= new_bib_number.to_i && new_bib_number.to_i <= max_possible_bib_number
  end

  # clean out a bib number, if anyone currently occupies it
  def self.free_bib_number(bib_number)
    reg = Registrant.find_by(bib_number: bib_number)
    return if reg.nil?
    new_bib_number = reg.registrant_type_model.next_available_bib_number
    reg.update(bib_number: new_bib_number)
  end
end
