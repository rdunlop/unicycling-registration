class CategoryPolicy < ApplicationPolicy
  def contact_registrants?
    event_planner? || super_admin?
  end
end
