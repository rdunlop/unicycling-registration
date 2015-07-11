class CompetitionPolicy < ApplicationPolicy

  # Can this user manage the lane assignments for the competition?
  def manage_lane_assignments?
    user.has_role?(:race_official, record) || admin? || super_admin?
  end

end
