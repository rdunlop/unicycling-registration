# Given a set of time_results, and a competition_start_time,
# determine the best time
class TimeResultCalculator
  attr_accessor :start_times, :finish_times, :competition_start_time, :lower_is_better

  def initialize(start_times, finish_times, competition_start_time, lower_is_better)
    @start_times = start_times
    @finish_times =  finish_times
    @competition_start_time = competition_start_time
    @lower_is_better = lower_is_better
  end

  def best_time_in_thousands
    best_finish_time = 0
    finish_times.each do |ft|
      matching_start_time = start_times.select{ |t| t < ft}.sort.max || (competition_start_time * 1000)
      new_finish_time = ft - matching_start_time
      if best_finish_time == 0 || (new_finish_time == better_time(best_finish_time, new_finish_time))
        best_finish_time = new_finish_time
      end
    end
    best_finish_time
  end

  private

  def better_time(time_1, time_2)
    if lower_is_better
      if time_1 < time_2
        time_1
      else
        time_2
      end
    else
      if time_1 < time_2
        time_2
      else
        time_1
      end
    end
  end

end
