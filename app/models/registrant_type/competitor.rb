module RegistrantType
  class Competitor
    INITIAL = 1
    MAXIMUM = 1999

    # Finds the free-option setting, if one is found for this registrant
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
      (INITIAL..MAXIMUM).each do |number|
        return number if Registrant.where(bib_number: number).none?
      end
    end
  end
end
