# The item has a cost
# and is thus associated with an ExpenseItem
module CostItem
  extend ActiveSupport::Concern

  included do
    has_one :expense_item, as: :cost_element
  end

  def has_cost?
    expense_item.present?
  end

  # Set up the necessary RegistrantExpenseItems for all registrants
  # which are affected by this CostItem
  def create_for_all_registrants
    raise "Not Implemented"
  end
end
