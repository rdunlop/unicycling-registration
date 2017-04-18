class CreatesRegistrationCost
  attr_accessor :registration_cost

  def initialize(registration_cost)
    @registration_cost = registration_cost
  end

  def perform
    return false if registration_cost.registration_cost_entries.none?

    registration_cost.registration_cost_entries.each do |rce|
      cei = rce.expense_item
      cei.expense_group = reg_expense_group
      cei.name = rce.to_s

      if rce.expense_item.new_record?
        cei.position = (reg_expense_group.expense_items.map(&:position).max || 0) + 1
      end
    end

    registration_cost.save
  end

  private

  # create the expense_group if necessary
  def reg_expense_group
    @reg_expense_group ||= ExpenseGroup.registration_items_group
  end
end
