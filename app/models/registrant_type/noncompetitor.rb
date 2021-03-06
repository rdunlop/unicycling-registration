module RegistrantType
  class Noncompetitor
    def options(expense_group, registrant)
      expense_group.expense_group_options.for("noncompetitor", registrant.age).map(&:option)
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_item_from_expense_groups(registrant_age)
      ExpenseGroupOption.where(
        option: [ExpenseGroupOption::ONE_IN_GROUP_REQUIRED, ExpenseGroupOption::EXACTLY_ONE_IN_GROUP_REQUIRED]
      ).for("noncompetitor", registrant_age).map(&:expense_group)
    end

    def required_expense_groups
      ExpenseGroup.where(noncompetitor_required: true)
    end

    def next_available_bib_number
      BibNumberFinder::FreeNumber.new("noncompetitor").next_available_bib_number
    end
  end
end
