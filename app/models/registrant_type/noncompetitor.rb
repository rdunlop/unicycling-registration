class RegistrantType
  class Noncompetitor
    def free_options(expense_group)
      expense_group.noncompetitor_free_options
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_free_expense_groups
      ExpenseGroup.where(noncompetitor_free_options: "One Free In Group REQUIRED")
    end

    def required_expense_groups
      ExpenseGroup.where(noncompetitor_required: true)
    end

    def next_available_bib_number
      max_bib_number = current_max_bib_number
      return (max_bib_number + 1) if max_bib_number.present?

      # defaults
      2001
    end

    private

    def current_max_bib_number
      Registrant.where.not(registrant_type: 'competitor').maximum("bib_number")
    end
  end
end
