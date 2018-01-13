module RegistrantType
  class Competitor
    def free_options(expense_group, registrant)
      expense_group.expense_group_free_options.for("competitor", registrant.age).first.try(:free_option)
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_free_expense_groups(registrant_age)
      ExpenseGroupFreeOption.where(free_option: "One Free In Group REQUIRED").for("competitor", registrant_age).map(&:expense_group)
    end

    def required_expense_groups
      ExpenseGroup.where(competitor_required: true)
    end

    def next_available_bib_number
      BibNumberFinder::FreeNumber.new("competitor").next_available_bib_number
    end
  end
end
