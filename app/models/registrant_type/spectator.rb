module RegistrantType
  class Spectator
    def free_options(_expense_group, _registrant)
      nil
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_free_expense_groups(_registrant_age)
      []
    end

    def required_expense_groups
      []
    end

    def next_available_bib_number
      BibNumberFinder::FreeNumber.new("spectator").next_available_bib_number
    end
  end
end
