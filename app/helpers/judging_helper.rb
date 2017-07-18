module JudgingHelper
  def num_total_columns(competition)
    if display_multiple_score_totals?(competition)
      3
    else
      2
    end
  end

  def display_multiple_score_totals?(competition)
    competition.score_ineligible_competitors?
  end
end
