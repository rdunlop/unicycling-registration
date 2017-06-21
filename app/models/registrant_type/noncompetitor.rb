class RegistrantType
  class Noncompetitor
    INITIAL = 2001
    MAXIMUM = 9999

    def free_options(expense_group, _registrant)
      expense_group.expense_group_free_options.where(registrant_type: "noncompetitor").first.try(:free_option)
      # expense_group.noncompetitor_free_options
    end

    # Returns a collection of ExpenseGroups which are required to have items selected
    def required_free_expense_groups(_registrant_age)
      ExpenseGroupFreeOption.where(registrant_type: "noncompetitor", free_option: "One Free In Group REQUIRED").map(&:expense_group)
      # ExpenseGroup.where(noncompetitor_free_options: "One Free In Group REQUIRED")
    end

    def required_expense_groups
      ExpenseGroup.where(noncompetitor_required: true)
    end

    def next_available_bib_number
      (INITIAL..MAXIMUM).each do |number|
        return number if Registrant.where(bib_number: number).none?
      end
    end
  end
end
