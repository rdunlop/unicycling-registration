class ImportPolicy < ApplicationPolicy
  def index?
    event_planner? || super_admin?
  end

  def import_registrants?
    event_planner? || super_admin?
  end

  def create?
    super_admin?
  end
end
