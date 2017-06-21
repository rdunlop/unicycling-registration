class RegistrantGroupTypePolicy < ApplicationPolicy
  def index?
    # for normal users, must be signed in, that's it
    manage?
  end

  def new?
    manage?
  end

  def show?
    manage?
  end

  def create?
    specific_director?
  end

  def destroy?
    specific_director?
  end

  def edit?
    specific_director?
  end

  def update?
    specific_director?
  end

  private

  def manage?
    director? || event_planner? || super_admin?
  end

  def specific_director?
    director?(record.source_element) || event_planner? || super_admin?
  end
end
