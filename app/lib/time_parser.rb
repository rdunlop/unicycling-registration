class TimeParser
  attr_accessor :full_time

  def initialize(full_time)
    @full_time = full_time
  end

  def result
    results = {}

    if full_time.index(":").nil?
      # no minutes
      results[:minutes] = 0
      seconds_and_hundreds = full_time
    else
      split_by_minutes = full_time.split(':')
      if split_by_minutes.length == 3
        hours = split_by_minutes[0].to_i
        minutes = split_by_minutes[1].to_i
        results[:minutes] = minutes + (hours * 60)
      else
        results[:minutes] = split_by_minutes[0].to_i # full_time[0..(full_time.index(":")-1)].to_i
      end
      seconds_and_hundreds = split_by_minutes[-1] # full_time[full_time.index(":")+1..-1]
    end

    index = seconds_and_hundreds.index(".")
    return nil if index.nil? # no decimal place found

    results[:seconds] = seconds_and_hundreds[0..(index - 1)].to_i

    thous = seconds_and_hundreds[(index + 1)..-1]
    if thous.length == 1
      results[:thousands] = thous.to_i * 100
    else
      results[:thousands] = thous.to_i
    end

    results
  end
end
