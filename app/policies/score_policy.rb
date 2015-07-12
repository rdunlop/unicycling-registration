class ScorePolicy < ApplicationPolicy

  def index?
    data_entry_volunteer? || director? || super_admin?
  end

  def create?
    return false if record.competitor.competition.locked?
    (user_match? && data_entry_volunteer?) || director?(record.competition.event) || super_admin?
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
