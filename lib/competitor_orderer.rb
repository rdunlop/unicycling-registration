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
end
