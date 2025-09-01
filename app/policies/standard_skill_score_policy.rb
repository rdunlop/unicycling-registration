class StandardSkillScorePolicy < ApplicationPolicy
  # def index? is handled by `judge.create_scores?`

  def new?
    permitted?
  end

  def edit?
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

  def judge_match?
    record.judge.user == user
  end

  def permitted?
    return false unless record.competition.unlocked?
    return true if super_admin? || director?(record.event)

    judge_match?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if super_admin?
        scope
      else
        scope.none
      end
    end
  end
end
