module EventsHelper
  def scoring_link(judge, options = {})
    class_name = judge.competition.event_class

    case class_name
    when 'High/Long'
      link_to "#{judge.competition} - #{judge.judge_type.name}", judge_distance_attempts_path(judge), options
    when 'Freestyle', "Artistic Freestyle IUF 2015"
      link_to "#{judge.competition} - #{judge.judge_type.name}", judge_scores_path(judge), options
    when 'Flatland'
      link_to judge.judge_type.name, competition_competitors_path(judge.competition), options
    when 'Street'
      link_to judge.judge_type.name, judge_street_scores_path(judge), options
    when 'Standard'
      link_to judge.judge_type.name, competition_standard_scores_path(judge.competition), options
    else
      "please update the scoring_link function (#{judge.competition.event_class})"
    end
  end

  def start_finish_description(is_start_time)
    is_start_time = false if is_start_time == "false"
    is_start_time ? "Start Line Data" : "Finish Line Data"
  end
end
