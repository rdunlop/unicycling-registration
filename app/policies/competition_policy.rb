class CompetitionPolicy < ApplicationPolicy

  # Can this user manage the lane assignments for the competition?
  def manage_lane_assignments?
    user.has_role?(:race_official, record) || admin? || super_admin?
  end

  def show?
    director?(record.event) || awards_admin? || data_entry_volunteer? || competition_admin? || super_admin?
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end

end
