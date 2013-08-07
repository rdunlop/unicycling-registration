class ArtisticScoreCalculator

    def initialize(competition, unicon_scoring = true)
        @competition = competition # should use this some where in the calculations?
        @unicon_scoring = unicon_scoring # should do 'elimination' for each judge_type
    end

    def update_all_places
      @competition.competitors.each do |competitor|
        place(competitor)
      end
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

        my_place = calc_place(score)

        total_points = 0
        ties(score).times do
          total_points = total_points + my_place 
          my_place = my_place + 1
        end
        @calc_points[score.id] = (total_points * 1.0) / ties(score)
    end
    def ties(score) # always has '1' tie...with itself
        ties = 0
        score.judge.get_scores.each do |each_score|
            if each_score.Total == score.Total
                ties = ties + 1
            end
        end
        ties
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
      @place ||= {}
      unless @place[competitor.id].nil?
        return @place[competitor.id]
      end
      my_place = 1
      my_points = total_points(competitor)
      competitor.competition.competitors.each do |comp|
        comp_points = total_points(comp)
        next if comp_points == 0
        if comp_points < my_points
            my_place = my_place + 1
        elsif comp_points == my_points
           if comp != competitor
               jt = JudgeType.find_by_name("Technical") # TODO this should be properly identified
               if total_points(comp, jt) < total_points(competitor, jt)
                   my_place = my_place + 1
               end
           end
        end
      end
      if my_points == 0
        my_place = 0
      end
      competitor.place = my_place
      competitor.overall_place = my_place
      @place[competitor.id] = my_place
    end

    def get_relevant_scores(competitor, judge_type)
      if judge_type.nil?
        scores = competitor.scores
      else
        scores = competitor.scores.select {|s| judge_type == s.judge.judge_type }
      end
      scores = scores.map {|s| calc_points(s)}
      scores
    end

    def total_points(competitor, judge_type = nil)
      # only caching the most common query
      if judge_type.nil?
        @total_points ||= {}
        unless @total_points[competitor.id].nil?
          # Enabling this cache breaks flatland judging...don't know why XXX
          #return @total_points[competitor.id]
        end
      end

      if judge_type.nil?
          total = 0
          competitor.competition.judge_types.uniq.each do |jt|
            total += total_points_for_judge_type(competitor, jt)
          end
      else
          total = total_points_for_judge_type(competitor, judge_type)
      end

      if judge_type.nil?
        @total_points[competitor.id] = total
      else
        total
      end
    end

    def total_points_for_judge_type(competitor, judge_type)
      scores = get_relevant_scores(competitor, judge_type)

      unless scores.count > 2
        return 0
      end

      min = lowest_score(competitor, judge_type)
      max = highest_score(competitor, judge_type)

      total_points = scores.reduce(:+) # sum the remaining values

      (total_points - min - max)
    end

    def highest_score(competitor, judge_type = nil)
      if @unicon_scoring
        get_relevant_scores(competitor, judge_type).max
      else
        # determine the score-to-be-eliminated
        #  and then determine if the chosen judge_type has the first occurrence of that score
        #  and if so, return it, otherwise, don't
        scores = competitor.scores
        scores = scores.map {|s| calc_points(s)}
        max = scores.max

        if judge_type.nil?
          max
        else
          scores = competitor.scores
          scores.each do |s|
            if calc_points(s) == max
                if judge_type == s.judge.judge_type
                    return max
                else
                    return 0
                end
            end
          end
        end
      end
    end
    
    def lowest_score(competitor, judge_type = nil)
      if @unicon_scoring
        get_relevant_scores(competitor, judge_type).min
      else
        # determine the score-to-be-eliminated
        #  and then determine if the chosen judge_type has the first occurrence of that score
        #  and if so, return it, otherwise, don't
        scores = competitor.scores
        scores = scores.map {|s| calc_points(s)}
        min = scores.min

        if judge_type.nil?
          min
        else
          scores = competitor.scores
          scores.each do |s|
            if calc_points(s) == min
                if judge_type == s.judge.judge_type
                    return min
                else
                    return 0
                end
            end
          end
        end
      end
    end
end
