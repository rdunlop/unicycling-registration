module CompetitorsHelper
  def conditional_form_for(models, condition, &block)
    if condition
        form_for(models, &block)
    else
        block.call(nil)
        return nil
    end
  end

  def start_data_entry_link(user, competition)
    case competition.start_data_type
    when "Two Attempt Distance"
      link_to "Two-Attempt Entry", user_competition_two_attempt_entries_path(user, competition, is_start_time: true)
    when "Single Attempt"
      link_to "Single ", user_competition_single_attempt_entries_path(user, competition, is_start_times: true)
    end

  end

  def end_data_entry_link(user, competition)
    case competition.end_data_type
    when "Two Attempt Distance"
      link_to "Two-Attempt Entry", user_competition_two_attempt_entries_path(user, competition, is_start_time: false)
    when "Single Attempt"
      link_to "Single", user_competition_single_attempt_entries_path(user, competition, is_start_times: false)
    end
  end
end
