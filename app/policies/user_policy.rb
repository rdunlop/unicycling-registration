class UserPolicy < ApplicationPolicy

  def registrants?
    record == user || payment_admin? || event_planner? || super_admin?
  end

  def logged_in?
    true
  end

end
