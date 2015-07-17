class ScorePolicy < ApplicationPolicy
  def create?
    return false if record.competitor.competition.locked?
    (user_match? && data_entry_volunteer?) || director?(record.competition.event) || super_admin?
  end

  # used for steret scores
  def destroy?
    create?
  end

  private

  def user_match?
    record.judge.user == user
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
