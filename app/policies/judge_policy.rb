class JudgePolicy < ApplicationPolicy

  def create_scores?
    record.competition.unlocked? && (user_match? || super_admin?)
  end

  private

  def user_match?
    record.user == user
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end

end
