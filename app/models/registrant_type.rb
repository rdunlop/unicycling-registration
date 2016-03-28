class RegistrantType
  attr_accessor :registrant_type

  def initialize(registrant_type)
    @registrant_type = registrant_type
  end

  def free_options(expense_group)
    if competitor?
      expense_group.competitor_free_options
    elsif noncompetitor?
      expense_group.noncompetitor_free_options
    end
  end

  # Returns a collection of ExpenseGroups which are required to have items selected
  def required_free_expense_groups
    if competitor?
      ExpenseGroup.where(competitor_free_options: "One Free In Group REQUIRED")
    elsif noncompetitor?
      ExpenseGroup.where(noncompetitor_free_options: "One Free In Group REQUIRED")
    else
      # Spectator
      []
    end
  end

  def required_expense_groups
    if competitor?
      ExpenseGroup.where(competitor_required: true)
    elsif noncompetitor?
      ExpenseGroup.where(noncompetitor_required: true)
    else
      []
    end
  end

  def next_available_bib_number
    max_bib_number = current_max_bib_number
    return (max_bib_number + 1) if max_bib_number.present?

    # defaults
    if competitor?
      1
    else
      2001
    end
  end

  private

  def current_max_bib_number
    if competitor?
      Registrant.competitor.maximum("bib_number")
    else
      Registrant.where.not(registrant_type: 'competitor').maximum("bib_number")
    end
  end

  def competitor?
    registrant_type == 'competitor'
  end

  def noncompetitor?
    registrant_type == 'noncompetitor'
  end
end
