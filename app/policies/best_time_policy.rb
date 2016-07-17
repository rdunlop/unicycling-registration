class BestTimePolicy < ApplicationPolicy
  def show?
    update?
  end

  def update?
    event_planner? || super_admin?
  end
end
