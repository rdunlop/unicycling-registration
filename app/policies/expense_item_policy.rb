class ExpenseItemPolicy < ApplicationPolicy
  def contact_registrants?
    event_planner? || super_admin?
  end
end
