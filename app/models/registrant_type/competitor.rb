class RegistrantType
  class Competitor
    INITIAL = 1
    def free_options(expense_group)
      expense_group.competitor_free_options
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_free_expense_groups
      ExpenseGroup.where(competitor_free_options: "One Free In Group REQUIRED")
    end

    def required_expense_groups
      ExpenseGroup.where(competitor_required: true)
    end

    def next_available_bib_number
      max_bib_number = current_max_bib_number
      return (max_bib_number + 1) if max_bib_number.present?

      # defaults
      INITIAL
    end

    private

    def current_max_bib_number
      Registrant.competitor.maximum("bib_number")
    end
  end
end
