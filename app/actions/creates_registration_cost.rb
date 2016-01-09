class CreatesRegistrationCost
  attr_accessor :registration_cost

  def initialize(registration_cost)
    @registration_cost = registration_cost
  end

  def perform
    return false if registration_cost.expense_item.nil?

    if registration_cost.expense_item.new_record?
      cei = registration_cost.expense_item
      set_details(cei, "#{registration_cost.registrant_type} - #{registration_cost.name}")
    end

    registration_cost.save
  end

  private

  def set_details(expense_item, name)
    expense_item.expense_group = reg_expense_group
    expense_item.name = name
    expense_item.position = (reg_expense_group.expense_items.map(&:position).max || 0) + 1
  end

  # create the expense_group if necessary
  def reg_expense_group
    @reg_expense_group ||= ExpenseGroup.registration_items_group
  end
end
