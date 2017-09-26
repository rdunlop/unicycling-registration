class EventPolicy < ApplicationPolicy
  def sign_ups?
    director?(record) || event_planner? || competition_admin? || super_admin?
  end

  def summary?
    manage?
  end

  def general_volunteers?
    manage?
  end

  def specific_volunteers?
    manage?
  end

  def results?
    director?(record)
  end

  def contact_registrants?
    director?(record) || event_planner? || super_admin?
  end

  private

  def manage?
    director? || event_planner? || super_admin?
  end
end
