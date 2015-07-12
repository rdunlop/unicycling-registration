class EventCategoryPolicy < ApplicationPolicy

  def sign_ups?
    director? || event_planner? || super_admin?
  end

end
