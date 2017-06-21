class RegistrantType
  class Spectator
    INITIAL = 2001
    MAXIMUM = 9999

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
      max_bib_number = current_max_bib_number
      return (max_bib_number + 1) if max_bib_number.present?

      # defaults
      INITIAL
    end

    private

    def current_max_bib_number
      Registrant.where.not(registrant_type: 'competitor').maximum("bib_number")
    end
  end
end
