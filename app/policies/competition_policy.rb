class CompetitionPolicy < ApplicationPolicy

  # Can this user manage the lane assignments for the competition?
  def manage_lane_assignments?
    user.has_role?(:race_official, record) || admin? || super_admin?
  end

  def create?
    competition_admin? || super_admin?
  end

  def update?
    competition_admin? || super_admin?
  end

  def destroy?
    competition_admin? || super_admin?
  end

  def show?
    director?(record.event) || awards_admin? || data_entry_volunteer? || competition_admin? || super_admin?
  end

  def sort?
    record.unlocked? && (director?(record.try(:event)) || competition_admin? || super_admin?)
  end

  ###### START State Machine transitions ############
  def lock?
    record.unlocked? && (director?(record.try(:event)) || competition_admin? || super_admin?)
  end

  def unlock?
    competition_admin?
  end

  def publish?
    awards_admin?
  end

  def unpublish?
    awards_admin?
  end

  def award?
    awards_admin?
  end
  ###### END State Machine transitions ############

  def export_scores?
    director?(record.event) || super_admin?
  end

  # printing/results
  def results?
    director(record.event) || awards_admin? || super_admin?
  end

  def result?
    director?(record.event) || super_admin?
  end

  def set_places?
    competition_admin?
  end


  private

  def sortable?
    record.unlocked? && (director?(record.try(:event)) || competition_admin? || super_admin?)
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end

end
