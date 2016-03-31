class StandardSkillRoutinePolicy < ApplicationPolicy
  # #####################
  # User Methods
  # #####################
  def index?
    return true if super_admin?
    return false unless config.standard_skill?

    true
  end

  def show?
    index?
  end

  def create?
    permitted?
  end

  def update?
    permitted?
  end

  def destroy?
    permitted?
  end

  # #####################
  # Admin Methods
  # #####################
  def export?
    view_all?
  end

  def view_all?
    return false unless config.standard_skill?
    event_planner? || super_admin?
  end

  private

  def permitted?
    return true if super_admin?
    return false if config.standard_skill_closed?
    user.registrants.include?(record.registrant)
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
