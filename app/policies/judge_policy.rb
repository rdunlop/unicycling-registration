class JudgePolicy < ApplicationPolicy
  def create_scores?
    record.competition.unlocked? && (user_match? || director?(record.event) || super_admin?)
  end

  def view_scores?
    (user_match? || director?(record.event) || super_admin?)
  end

  def index?
    director?(record.event) || super_admin?
  end

  def toggle_status?
    director?(record.event) || super_admin?
  end

  def create?
    update?
  end

  def update?
    record.scores.count.zero? && record.competition.unlocked? && (director?(record.event) || super_admin?)
  end

  def destroy?
    update?
  end

  def can_judge?
    record.competition.unlocked? && (user_match? || director?(record.event) || super_admin?)
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
