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
    director?(record.event) || awards_admin? || competition_admin? || super_admin?
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

  def publish_age_group_entry?
    track_data_importer?(record) || publish?
  end

  def publish?
    awards_admin? || super_admin?
  end

  def unpublish?
    awards_admin? || super_admin?
  end

  def award?
    !record.awarded? && (awards_admin? || super_admin?)
  end

  def unaward?
    record.awarded? && (awards_admin? || super_admin?)
  end

  ###### END State Machine transitions ############

  def export_scores?
    director?(record.event) || super_admin?
  end

  def export_times?
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
    director?(record.event) || competition_admin? || super_admin?
  end

  def add_additional_results?
    director?(record.event) || competition_admin? || super_admin?
  end

  def destroy_all_results?
    (record.imports_times? || record.imports_points?) && create_preliminary_result?
  end

  # PRINTING
  def heat_recording?
    view_access?
  end

  # DATA MANAGEMENT
  # This is the person who can see entered data for all judges/entry for a competition
  def view_result_data?
    track_data_importer?(record) || director?(record.event) || super_admin?
  end

  def modify_result_data?
    record.unlocked? && view_result_data?
  end

  def single_attempt_recording?
    view_access?
  end

  def two_attempt_recording?
    view_access?
  end

  def start_list?
    true
  end

  # DATA ENTRY
  # Can enter preliminary data for a competition
  def create_preliminary_result?
    record.unlocked? && view_access?
  end

  def enter_sign_ins?
    record.sign_in_list? && create_preliminary_result?
  end

  def view_sign_ins?
    record.sign_in_list? && view_access?
  end

  def manage_volunteers?
    director?(record.event) || super_admin?
  end

  def set_age_group_places?
    track_data_importer?(record) || director?(record.event) || super_admin?
  end

  def assign_tiers?
    record.uses_tiers? && (director?(record.event) || competition_admin? || super_admin?)
  end

  private

  def view_access?
    track_data_importer?(record) || data_recording_volunteer?(record) || director?(record.event) || super_admin?
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
