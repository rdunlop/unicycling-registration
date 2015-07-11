class UserPolicy < ApplicationPolicy

  def registrants?
    record == user || payment_admin? || event_planner? || super_admin?
  end

  def create_payments?
    !reg_closed? || super_admin?
  end

  def logged_in?
    true
  end

end
