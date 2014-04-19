class FlatlandScoreCalculator < ArtisticScoreCalculator

    # ####################################################################
    #   BY SCORE (JUDGE)
    # ####################################################################
    # determining the place points for this score (by-judge)

  def get_placing_points_for_judge_type(competitor, judge_type)
    if judge_type.nil?
      scores = competitor.scores
    else
      scores = competitor.scores.select {|s| judge_type == s.judge_type }
    end
    scores.map {|s| s.total.to_i }
  end

    # ####################################################################
    #   BY EVENT (all scores, all judges)
    # ####################################################################
    #
    # this should be in "Competitor", but I'm putting here because
    # I don't want to clutter Competitor (which is not always Score-based)
    #
    def place(competitor)
      @place ||= {}
      unless @place[competitor.id].nil?
        return @place[competitor.id]
      end

      my_points = total_points(competitor)
      total_points_per_competitor     = competitor.competition.competitors.map { |comp| total_points(comp) }

      my_tie_break_points = total_last_trick_points(competitor, nil)
      tie_break_points_per_competitor = competitor.competition.competitors.map { |comp|  total_last_trick_points(comp, nil) }

      my_place = new_place(my_points, total_points_per_competitor, my_tie_break_points, tie_break_points_per_competitor, false)

      @place[competitor.id] = my_place
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

        totals = scores.map {|s| s.total}

        # choose a 'score' object which is going to be removed
        #  because it's the 'max' and 'min' object(s)
        max = scores.select {|s| s.total == totals.max }.first.val_4
        min = scores.select {|s| s.total == totals.min }.first.val_4

        last_trick_scores = scores.map {|s| s.val_4.to_i}
        total = 0
        last_trick_scores.each do |s|
            total += s
        end

        total - max - min
    end
end
