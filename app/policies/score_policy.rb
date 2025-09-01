class ScorePolicy < ApplicationPolicy
  def create?
    return false if record.competitor.competition.locked?

    user_match? || director?(record.competition.event) || super_admin?
  end

  # used for steret scores
  def destroy?
    create?
  end

  private

  def user_match?
    record.judge.user == user
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
