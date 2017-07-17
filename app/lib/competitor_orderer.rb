class CompetitorOrderer
  attr_reader :competitors, :lower_is_better, :use_with_ineligible_score

  # competitors must respond to:
  #  - comparable_score
  #  - comparable_tie_break_score
  def initialize(competitors, lower_is_better = true, use_with_ineligible_score: true)
    @competitors = competitors
    @lower_is_better = lower_is_better
    @use_with_ineligible_score = use_with_ineligible_score
  end

  def sort
    @sorted ||= competitors.sort{ |a, b| compare_competitors(a, b) }
  end

  private

  def competitor_score(competitor)
    if use_with_ineligible_score
      competitor.comparable_score_with_ineligible
    else
      competitor.comparable_score
    end
  end

  # return 1 if first score is worse than the second score
  # return 0 if they are the same
  # return -1 if the first score is better than the second score
  def compare_competitors(a, b)
    if either_score_is_invalid(a, b)
      return incorrect_scores_last(competitor_score(a), competitor_score(b))
    end

    if lower_is_better
      first_competitor = a
      second_competitor = b
    else
      first_competitor = b
      second_competitor = a
    end

    res = competitor_score(first_competitor) <=> competitor_score(second_competitor)
    if res.to_f.zero?
      if score_is_invalid(a.comparable_tie_break_score) || score_is_invalid(b.comparable_tie_break_score)
        return incorrect_scores_last(a.comparable_tie_break_score, b.comparable_tie_break_score)
      end
      first_competitor.comparable_tie_break_score <=> second_competitor.comparable_tie_break_score
    else
      res
    end
  end

  def either_score_is_invalid(a, b)
    return true if score_is_invalid(competitor_score(a))
    return true if score_is_invalid(competitor_score(b))
    false
  end

  def score_is_invalid(score)
    return true if score.is_a?(Float) && score.nan?
    return true if score.nil?

    false
  end

  # return 1 if first score is invalid, but the second is valid
  # return 0 if they are the same
  # return -1 if the first score is valid, and the second is invalid
  def incorrect_scores_last(a, b)
    invalid_a = score_is_invalid(a)
    invalid_b = score_is_invalid(b)
    if invalid_a && invalid_b
      0
    elsif invalid_a && !invalid_b
      1
    elsif !invalid_a && invalid_b
      -1
    else
      0
    end
  end
end
