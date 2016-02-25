class CompetitorPolicy < ApplicationPolicy
  def index?
    director?(record.competition.event) || competition_admin? || super_admin?
  end

  def new?
    manage?
  end

  def display_candidates?
    manage?
  end

  def create_from_candidates?
    manage?
  end

  def add?
    manage?
  end

  def edit?
    manage?
  end

  def add_all?
    manage?
  end

  def create?
    return false unless record.competition.unlocked?
    director_or_competition_admin?(user, record.competition) || config.can_create_competitors_at_lane_assignment?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  def withdraw?
    manage?
  end

  def destroy_all?
    manage?
  end

  def sort?
    manage?
  end

  private

  def director_or_competition_admin?(_user, competition)
    director?(competition.try(:event)) || competition_admin? || super_admin?
  end

  def manage?
    # can [:manage, :update_row_order], Competitor do |comp|

    record.competition.unlocked? && director_or_competition_admin?(user, record.competition)
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
