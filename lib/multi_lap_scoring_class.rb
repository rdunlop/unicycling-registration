class MultiLapScoringClass < RaceScoringClass
  def scoring_description
    "Each competitor may have multiple time results. A time result is made up
    of an optional 'start time' and a required 'end time'. The #{lower_is_better ? 'Faster' : 'Slower'} time
    is used to determine the placing of the competitor. The Higher 'Number of Laps' always place higher
    than lower ones."
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if self.competitor_has_result?(competitor)
      TimeResultPresenter.new(competitor.best_time_in_thousands).full_time.to_s + " (" + competitor.num_laps.to_s + " laps)"
    else
      nil
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if self.competitor_has_result?(competitor)
      lap_time(competitor.num_laps) + competitor.best_time_in_thousands
    else
      0
    end
  end

  # convert 1 lap int 9900000000, 2 laps into 980000000000....thus sorting by shortest time correctly.
  def lap_time(num_laps)
    raise "Unable to process >= 100 laps" if num_laps >= 100
    ((100 - num_laps) * 100000000)
  end
end
