class StandardSkillRoutinePolicy < ApplicationPolicy
  def index?
    return true if super_admin?
    return false if config.standard_skill_closed?

    true
  end

  def show?
    permitted?
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
