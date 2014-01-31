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

    def scores_link(competition)
      class_name = competition.event_class

      case class_name
      when'Two Attempt Distance'
      when 'Freestyle'
        link_to 'View Scores', freestyle_scores_competition_path(competition)
      when 'Flatland'
      when 'Street'
        link_to 'View Scores', street_scores_competition_path(competition)
      when 'Standard'
        #link_to 'View Scores', judge_standard_scores_path(judge)
      else
        "please update the scores_link function (#{competition.event_class})"
      end
    end

    def results_url(competition)
      case competition.event.event_class
      when "Distance"
        competition.scoring_helper.results_path
      when "Ranked"
        competition_external_results_path(competition)
      when "Freestyle"
        freestyle_scores_competition_path(competition)
      when "Two Attempt Distance"
        distance_attempts_competition_path(competition) 
      end
    end

    def judging_menu_url(competition)
      class_name = competition.event.event_class
      case class_name
      when'Two Attempt Distance'
        track_events_path
      when 'Freestyle'
        freestyle_events_path
      when 'Flatland'
        flatland_events_path
      when 'Street'
        street_events_path
      when "Distance"
        distance_events_path
      else
        root_path
      end
    end
end
