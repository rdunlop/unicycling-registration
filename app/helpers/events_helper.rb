module EventsHelper
    def scoring_link(judge)
        class_name = judge.competition.event_class

        case class_name
        when 'Two Attempt Distance'
          link_to "#{judge.competition} - #{judge.judge_type.name}", judge_distance_attempts_path(judge) 
        when 'Freestyle'
          link_to "#{judge.competition} - #{judge.judge_type.name}", judge_scores_path(judge) 
        when 'Flatland'
            link_to judge.judge_type.name, competition_competitors_path(judge.competition)
        when 'Street'
            link_to judge.judge_type.name, judge_street_scores_path(judge)
        when 'Standard'
            link_to judge.judge_type.name, competition_standard_scores_path(judge.competition)
        else
            "please update the scoring_link function (#{judge.competition.event_class})"
        end
    end

    def results_url(competition)
      competition.scoring_helper.results_path
    end
end
