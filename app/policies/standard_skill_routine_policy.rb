class StandardSkillRoutinePolicy < ApplicationPolicy
  # #####################
  # User Methods
  # #####################
  def index?
    # index is /en/standard_skill_routines,
    # and thus is not scoped to each user, and safe without checking for user match
    return false unless config.standard_skill?

    true
  end

  def writing_judge?
    view_blank_judging_sheets?
  end

  def show?
    view_blank_judging_sheets?
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

  def view_blank_judging_sheets?
    return true if super_admin? || event_planner?

    user.registrants.include?(record.registrant)
  end

  def permitted?
    return true if super_admin? || event_planner?
    return false if config.standard_skill_closed?
    user.registrants.include?(record.registrant)
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
