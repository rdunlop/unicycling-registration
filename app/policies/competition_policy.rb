class CompetitionPolicy < ApplicationPolicy
  # Can this user manage the lane assignments for the competition?
  def manage_lane_assignments?
    user.has_role?(:race_official, record) || super_admin?
  end

  def copy_judges?
    record.unlocked? && (director?(record.event) || super_admin?)
  end

  def index?
    director?(record.event) || super_admin?
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
    record.unlocked? && (director?(record.event) || competition_admin? || super_admin?)
  end

  ###### START State Machine transitions ############
  def lock?
    record.unlocked? && (director?(record.event) || competition_admin? || super_admin?)
  end

  def unlock?
    competition_admin? || super_admin?
  end

  def publish?
    awards_admin? || super_admin?
  end

  def unpublish?
    awards_admin? || super_admin?
  end

  def award?
    awards_admin? || super_admin?
  end
  ###### END State Machine transitions ############

  def export_scores?
    director?(record.event) || super_admin?
  end

  # printing/results
  def results?
    director?(record.event) || awards_admin? || super_admin?
  end

  def result?
    director?(record.event) || super_admin?
  end

  def set_places?
    competition_admin? || super_admin?
  end

  # PRINTING
  def announcer?
    return true # ?? Was "skip_authorization_check" before?
    data_entry_volunteer? || director?(record.event) || super_admin?
  end

  def heat_recording?
    data_entry_volunteer? || director?(record.event) || super_admin?
  end

  # DATA MANAGEMENT
  def view_result_data?
    director?(record.event) || super_admin?
  end

  def modify_result_data?
    record.unlocked? && view_result_data?
  end

  def single_attempt_recording?
    data_entry_volunteer? || director?(record.event) || super_admin?
  end

  def two_attempt_recording?
    data_entry_volunteer? || director?(record.event) || super_admin?
  end

  def start_list?
    true
  end

  # DATA ENTRY
  def create_preliminary_result?
    record.unlocked? && (data_entry_volunteer? || director?(record.event) || super_admin?)
  end

  def manage_volunteers?
    director?(record.event) || super_admin?
  end

  def publish_age_group_entry?
    super_admin?
  end

  def set_age_group_places?
    super_admin?
  end

  private

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
