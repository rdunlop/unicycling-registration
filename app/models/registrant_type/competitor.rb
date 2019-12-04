module RegistrantType
  class Competitor
    def options(expense_group, registrant)
      # Is this returning more than 1 option?
      expense_group.expense_group_options.for("competitor", registrant.age).map(&:option)
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_item_from_expense_groups(registrant_age)
      ExpenseGroupOption.where(
        option: [ExpenseGroupOption::ONE_IN_GROUP_REQUIRED, ExpenseGroupOption::EXACTLY_ONE_IN_GROUP_REQUIRED]
      ).for("competitor", registrant_age).map(&:expense_group)
    end

    def required_expense_groups
      ExpenseGroup.where(competitor_required: true)
    end

    def next_available_bib_number
      BibNumberFinder::FreeNumber.new("competitor").next_available_bib_number
    end
  end
end
