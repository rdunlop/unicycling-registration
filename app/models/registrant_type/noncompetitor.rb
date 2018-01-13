module RegistrantType
  class Noncompetitor
    def free_options(expense_group, registrant)
      expense_group.expense_group_free_options.for("noncompetitor", registrant.age).first.try(:free_option)
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_free_expense_groups(registrant_age)
      ExpenseGroupFreeOption.where(free_option: "One Free In Group REQUIRED").for("noncompetitor", registrant_age).map(&:expense_group)
    end

    def required_expense_groups
      ExpenseGroup.where(noncompetitor_required: true)
    end

    def next_available_bib_number
      BibNumberFinder::FreeNumber.new("noncompetitor").next_available_bib_number
    end
  end
end
