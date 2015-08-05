class CompetitorOrderer
  attr_reader :competitors, :lower_is_better

  def initialize(competitors, lower_is_better = true)
    @competitors = competitors
    @lower_is_better = lower_is_better
  end

  def sort
    @sorted ||= competitors.sort{ |a, b| compare_competitors(a, b) }
  end

  private

  # return 1 if first score is worse than the second score
  # return 0 if they are the same
  # return -1 if the first score is better than the second score
  def compare_competitors(a, b)
    return incorrect_scores_last(a,b) if either_score_is_invalid(a,b)

    if lower_is_better
      first_competitor = a
      second_competitor = b
    else
      first_competitor = b
      second_competitor = a
    end

    res = first_competitor.comparable_score <=> second_competitor.comparable_score
    if res == 0
      first_competitor.comparable_tie_break_score <=> second_competitor.comparable_tie_break_score
    else
      res
    end
  end

  def either_score_is_invalid(a,b)
    return true if score_is_invalid(a.comparable_score)
    return true if score_is_invalid(b.comparable_score)
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
    invalid_a = score_is_invalid(a.comparable_score)
    invalid_b = score_is_invalid(b.comparable_score)
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
