module CompetitorsHelper

  def data_recording_link(competition, options = {})
    case options[:is_start_times] ? competition.start_data_type : competition.end_data_type
    when "Two Attempt Distance"
      res = link_to "Two Attempt Recording", two_attempt_recording_printing_competition_path(competition, options)
      res += link_to "(pdf)", two_attempt_recording_printing_competition_path(competition, options.merge(:format => :pdf))
    when "Single Attempt"
      res = link_to "Blank Race Recording Forms", single_attempt_recording_printing_competition_path(competition, options)
      res += link_to "(pdf)", single_attempt_recording_printing_competition_path(competition, options.merge(:format => :pdf))
    when "Track E-Timer"
      res = link_to "Heats Recording Sheet", heat_recording_printing_competition_path(competition)
      res += link_to "(pdf)", heat_recording_printing_competition_path(competition, :format => :pdf)
    end
  end

  def data_confirmation_link(competition, options = {})
    link_to "View", review_user_competition_import_results_path(current_user, competition)
  end

  def start_data_entry_link(user, competition)
    case competition.start_data_type
    when "Two Attempt Distance"
      link_to "Two-Attempt Entry", user_competition_two_attempt_entries_path(user, competition, is_start_times: true)
    when "Single Attempt"
      link_to "Single ", user_competition_single_attempt_entries_path(user, competition, is_start_times: true)
    when "Track E-Timer"
      if competition.uses_lane_assignments
        res = link_to "Display Heat", view_heat_competition_lane_assignments_path(competition)
        res += link_to "Set Lane Assignments", competition_lane_assignments_path(competition)
      else
        "None Enabled"
      end
    end

  end

  def end_data_entry_link(user, competition)
    case competition.end_data_type
    when "Two Attempt Distance"
      link_to "Two-Attempt Entry", user_competition_two_attempt_entries_path(user, competition, is_start_times: false)
    when "Single Attempt"
      link_to "Single", user_competition_single_attempt_entries_path(user, competition, is_start_times: false)
    when "Track E-Timer"
      link_to "Track Importing", display_lif_user_competition_import_results_path(user, competition)
    when "Externally Ranked"
      link_to "Import CSV", display_csv_user_competition_import_results_path(user, competition)
    end
  end
end
