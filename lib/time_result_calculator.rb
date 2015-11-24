# Given a set of time_results, and a competition_start_time,
# determine the best time
class TimeResultCalculator
  attr_accessor :start_times, :finish_times, :competition_start_time, :lower_is_better

  def initialize(start_times, finish_times, competition_start_time, lower_is_better)
    @start_times = start_times
    @finish_times = finish_times
    @competition_start_time = competition_start_time
    @lower_is_better = lower_is_better
  end

  # If start_times are provided, find the last start time which begins before each finish time
  # If no start_time is given, use the "competition_start_time" which indicates an absolute start time
  # for this competitor (offset their end time by that amount)
  def best_time_in_thousands
    best_finish_time = 0
    finish_times.each do |ft|
      total_time = adjusted_time(ft)

      if best_finish_time == 0 || (total_time == better_time(best_finish_time, total_time))
        best_finish_time = total_time
      end
    end
    best_finish_time
  end

  private

  # given a finish time, determine the actual competition time by
  # finding a start_time, or using the overall competition_start_time
  def adjusted_time(finish_time)
    start_time = matching_start_time(finish_time) || competition_start_time_in_thousands
    finish_time - start_time
  end

  # return nil if there are no matching start times
  def matching_start_time(finish_time)
    start_times.select{ |t| t < finish_time}.sort.max
  end

  def competition_start_time_in_thousands
    competition_start_time * 1000
  end

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
