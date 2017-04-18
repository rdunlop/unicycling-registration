class CreatesRegistrationCost
  attr_accessor :registration_cost

  def initialize(registration_cost)
    @registration_cost = registration_cost
  end

  def perform
    return false if registration_cost.registration_cost_entries.none?

    registration_cost.registration_cost_entries.each do |rce|
      cei = rce.expense_item
      set_details(cei, rce.to_s)

      if rce.expense_item.new_record?
        set_position(cei)
      end
    end

    registration_cost.save
  end

  private

  def set_details(expense_item, name)
    expense_item.expense_group = reg_expense_group
    expense_item.name = name
  end

  def set_position(expense_item)
    expense_item.position = (reg_expense_group.expense_items.map(&:position).max || 0) + 1
  end

  # create the expense_group if necessary
  def reg_expense_group
    @reg_expense_group ||= ExpenseGroup.registration_items_group
  end
end
