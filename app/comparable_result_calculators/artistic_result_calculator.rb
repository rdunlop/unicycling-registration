class ArtisticResultCalculator
  def initialize(unicon_scoring = true)
    @unicon_scoring = unicon_scoring
  end

  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.any?
  end

  # returns the result to be displayed for this competitor
  def competitor_result(_competitor)
    nil
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor, with_ineligible: nil)
    if competitor.has_result?
      total_points(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    jt = JudgeType.find_by(name: "Technical", event_class: competitor.competition.event_class) # TODO: this should be properly identified
    total_points_for_judge_type(competitor, jt)
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      scores: [judge: :judge_type]
    )
  end

  # Must be 'public' so that we can show calculation steps on the chief-judge view
  def total_points(competitor)
    if @unicon_scoring
      total = 0
      competitor.competition.judge_types.uniq.each do |jt|
        total += total_points_for_judge_type(competitor, jt)
      end
    else
      total = total_points_for_judge_type(competitor, nil)
    end

    total
  end

  def total_points_for_judge_type(competitor, judge_type, with_ineligible: nil)
    scores = get_placing_points_for_judge_type(competitor, judge_type)

    unless scores.count > 2
      return 0
    end

    min = scores.min
    max = scores.max

    total_points = scores.reduce(:+) # sum the remaining values

    (total_points - min - max)
  end

  private

  def get_placing_points_for_judge_type(competitor, judge_type)
    if judge_type.nil?
      scores = competitor.scores
    else
      scores = competitor.scores.select {|s| judge_type == s.judge_type }
    end
    scores.map(&:placing_points).compact
  end

  # XXX Should the tie-break have to remove the SAME high/low judges?

  # 5.10.1 Removing The High And Low
  # After determining placing points as above, discard the highest and lowest placing score
  # for each rider. If Rider A has scores of 1,2,1,3,2, take out one of the ones, and the three.
  # Then Rider A has 1,2,2, for a total of 5. If Rider B has scores of 2,2,2,2,2, he will end
  # up with 2,2,2, a total of 6. The winner is the competitor with the lowest total placing
  # points score after the high and low have been removed.
  #
  # 5.10.2 Ties
  # If more than one competitor has the same placing score after the above process, those
  # riders will be ranked based on their placing scores for Technical. The scoring process
  # must be repeated using only the Technical scores for the tied riders to determine this
  # rank. High and low placing scores are again removed in the process. If competitors'
  # Technical ranking comes out equal, all competitors with the same score are awarded the
  # same place.
end
