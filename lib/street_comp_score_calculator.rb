class StreetCompScoreCalculator < ArtisticScoreCalculator

    def initialize(competition)
        @calc = ArtisticScoreCalculator.new(competition) # should use this some where in the calculations?
    end

    # ####################################################################
    #   BY SCORE (JUDGE)
    # ####################################################################
    # determining the place points for this score (by-judge)
    
    def calc_points(score)
        @calc_points ||= {}
        unless @calc_points[score.id].nil?
            return @calc_points[score.id]
        end

        # As per Rulebook
        points = [10, 7, 5, 3, 2, 1]

        my_place = calc_place(score)

        total_points = 0
        ties(score).times do
            total_points = total_points + (my_place < 7 ? points[my_place - 1] : 0)
            my_place = my_place + 1
        end
        @calc_points[score.id] = (total_points * 1.0) / ties(score)
    end

    def calc_place(score)
        @calc_place ||= {}
        unless @calc_place[score.id].nil?
            return @calc_place[score.id]
        end
        unless score.valid?
            return 0
        end

        my_place = 1
        score.judge.get_scores.each do |each_score|
            # Higher is better
            if each_score.Total > score.Total
                my_place = my_place + 1
            end
        end
        @calc_place[score.id] = my_place
    end




    # ####################################################################
    #   BY EVENT (all scores, all judges)
    # ####################################################################
    #
    # this should be in "Competitor", but I'm putting here because
    # I don't want to clutter Competitor (which is not always Score-based)
    def place(competitor)

      my_place = 1
      my_points = total_points(competitor)
      competitor.competition.competitors.each do |comp|
        comp_points = total_points(comp)
        if comp_points > my_points # XXX replace with helper function?
            my_place = my_place + 1
        end
      end
      my_place
    end
   def total_points_for_judge_type(competitor, judge_type)
      scores = get_relevant_scores(competitor, judge_type)

      total_points = scores.reduce(:+) # sum the values
    end
end
