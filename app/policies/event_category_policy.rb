class EventCategoryPolicy < ApplicationPolicy
  def sign_ups?
    director?(record.event) || event_planner? || super_admin?
  end
end
