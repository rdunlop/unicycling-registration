module EventsHelper
    def scoring_link(judge, options = {})
        class_name = judge.competition.event_class

        case class_name
        when 'Two Attempt Distance'
          link_to "#{judge.competition} - #{judge.judge_type.name}", judge_distance_attempts_path(judge), options
        when 'Freestyle'
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

    def results_url(competition)
      competition.scoring_helper.results_path
    end
end
