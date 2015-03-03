class CreatesRegistrationPeriod
  attr_accessor :registration_period

  def initialize(registration_period)
    @registration_period = registration_period
  end

  def perform
    return false if registration_period.competitor_expense_item.nil? || registration_period.noncompetitor_expense_item.nil?

    if registration_period.competitor_expense_item.new_record?
      cei = registration_period.competitor_expense_item
      set_details(cei, "Competitor - #{registration_period.name}")
    end

    if registration_period.noncompetitor_expense_item.new_record?
      cei = registration_period.noncompetitor_expense_item
      set_details(cei, "Non-Competitor - #{registration_period.name}")
    end

    registration_period.save
  end

  private

  def set_details(expense_item, name)
    expense_item.expense_group = reg_expense_group
    expense_item.name = name
    expense_item.description = name
    expense_item.position = (reg_expense_group.expense_items.map(&:position).max || 0) + 1
  end

  # create the expense_group if necessary
  def reg_expense_group
    @reg_expense_group ||= ExpenseGroup.registration_items_group
  end
end
