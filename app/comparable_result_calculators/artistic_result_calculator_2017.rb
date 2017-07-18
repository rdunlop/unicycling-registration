class ArtisticResultCalculator_2017
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.any?
  end

  # returns the result to be displayed for this competitor
  def competitor_result(_competitor)
    nil
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor, with_ineligible: false)
    if competitor.has_result?
      total_points(competitor, with_ineligible: with_ineligible)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    jt = JudgeType.find_by(name: "Technical", event_class: competitor.competition.event_class) # TODO: this should be properly identified
    total_points_for_judge_type(competitor, jt, with_ineligible: true)
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      scores: [judge: :judge_type]
    )
  end

  # Calculate the total number of points for a given competitor
  # judge_type: if specified, limit the results to a given judge_type.
  # NOTE: This function takes into account the "removed scores" by chief judge (eliminates them)
  #
  # return a numeric
  def total_points(competitor, with_ineligible: false)
    type_results = results_by_judge_type(competitor, with_ineligible: with_ineligible)

    calculate_weighted_total(type_results)
  end

  def total_points_with_ineligible(competitor)
    type_results = results_by_judge_type(competitor)

    calculate_weighted_total(type_results)
  end

  def dismount_points_for_competitor(competitor, dismount_judge_type)
    scores = competitor.scores.joins(:judge).where(judges: { judge_type_id: dismount_judge_type.id }).merge(Judge.active)

    majors = []
    minors = []

    scores.map do |score|
      majors << score.val_1
      minors << score.val_2
    end

    return { major_dismounts: 0, minor_dismounts: 0 } if majors.count.zero? || minors.count.zero?

    {
      major_dismounts: majors.sum / majors.count,
      minor_dismounts: minors.sum / minors.count
    }
  end

  def total_points_for_judge_type(competitor, judge_type, with_ineligible: false)
    scores = competitor.scores.joins(:judge).where(judges: { judge_type_id: judge_type.id }).merge(Judge.active)

    active_scores = scores.map{ |score| score.placing_points(with_ineligible: with_ineligible) }.compact

    return 0 if active_scores.none?

    (active_scores.sum / active_scores.count.to_f).round(2)
  end

  def results_by_judge_type(competitor, with_ineligible: false)
    competitor.competition.judge_types.uniq.map do |jt|
      {
        type: jt.name,
        total: total_points_for_judge_type(competitor, jt, with_ineligible: with_ineligible)
      }
    end
  end

  def calculate_weighted_total(type_results)
    weights = {
      "Performance" => 45,
      "Technical" => 45,
      "Dismount" => 10
    }.freeze

    type_results.map do |tr_entry|
      weights[tr_entry[:type]] * tr_entry[:total]
    end.sum / 100.0
  end
end
