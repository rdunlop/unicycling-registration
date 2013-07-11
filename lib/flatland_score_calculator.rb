class FlatlandScoreCalculator < ArtisticScoreCalculator

    def initialize(event_category)
        @calc = ArtisticScoreCalculator.new(event_category) # should use this some where in the calculations?
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

        @calc_points[score.id] = score.Total.to_i
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
      competitor.event_category.competitors.each do |comp|
        comp_points = total_points(comp)
        if comp_points > my_points # XXX replace with helper function?
            my_place = my_place + 1
        elsif comp_points == my_points
           if comp != competitor
               if total_last_trick_points(comp, nil) > total_last_trick_points(competitor, nil)
                   my_place = my_place + 1
               end
           end
        end
      end
      my_place
    end

    # the last_trick points are based on the judges that remain. (the judges that remain are calculated on 'Total')
    def total_last_trick_points(competitor, judge_type)
        if judge_type.nil?
            scores = competitor.scores
        else
            scores = competitor.scores.select {|s| judge_type == s.judge.judge_type }
        end
        if scores.count <= 2
            return 0
        end

        totals = scores.map {|s| s.Total}

        # choose a 'score' object which is going to be removed
        #  because it's the 'max' and 'min' object(s)
        max = scores.select {|s| s.Total == totals.max }.first.val_4
        min = scores.select {|s| s.Total == totals.min }.first.val_4

        last_trick_scores = scores.map {|s| s.val_4.to_i}
        total = 0
        last_trick_scores.each do |s|
            total += s
        end

        total - max - min
    end
end
