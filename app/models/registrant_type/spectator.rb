module RegistrantType
  class Spectator
    def options(_expense_group, _registrant)
      []
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_item_from_expense_groups(_registrant_age)
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
