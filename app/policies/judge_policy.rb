class JudgePolicy < ApplicationPolicy

  def create_scores?
    record.competition.unlocked? && (user_match? || super_admin?)
  end

  def index?
    director? || super_admin?
  end

  def toggle_status?
    director?(record.competition.event) || super_admin?
  end

  def create?
    update?
  end

  def update?
    (record.scores.count == 0) && record.competition.unlocked? && (director?(record.competition.event) || super_admin?)
  end

  def destroy?
    update?
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
