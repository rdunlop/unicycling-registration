module EventsHelper
    def scoring_link(judge)
        class_name = judge.competition.event.event_class

        if class_name == 'Two Attempt Distance'
          link_to "#{judge.competition} - #{judge.judge_type.name}", judge_distance_attempts_path(judge) 
        elsif class_name == 'Freestyle'
          link_to "#{judge.competition} - #{judge.judge_type.name}", judge_scores_path(judge) 
        elsif class_name == 'Flatland'
            link_to judge.judge_type.name, competition_competitors_path(judge.competition)
        elsif class_name == 'Street'
            link_to judge.judge_type.name, judge_street_scores_path(judge)
        elsif class_name == 'Standard'
            link_to judge.judge_type.name, competition_standard_scores_path(judge.competition)
        else
            "please update the scoring_link function (#{judge.competition.event.event_class})"
        end
    end

    def scores_link(competition)
      class_name = competition.event.event_class
        if class_name == 'Two Attempt Distance'
        elsif class_name == 'Freestyle'
            link_to 'View Scores', freestyle_scores_competition_path(competition)
        elsif class_name == 'Flatland'
        elsif class_name == 'Street'
            link_to 'View Scores', street_scores_competition_path(competition)
        elsif class_name == 'Standard'
            #link_to 'View Scores', judge_standard_scores_path(judge)
        else
            "please update the scores_link function (#{event.event_class})"
        end
    end

    def results_url(competition)
      case competition.event.event_class
      when "Distance"
        competition_time_results_path(competition)
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
      if class_name == 'Two Attempt Distance'
        track_events_path
      elsif class_name == 'Freestyle'
        freestyle_events_path
      elsif class_name == 'Flatland'
        flatland_events_path
      elsif class_name == 'Street'
        street_events_path
      elsif class_name == "Distance"
        distance_events_path
      else
        root_path
      end
    end
end
