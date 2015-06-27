module TimePrintable
  extend ActiveSupport::Concern

  # convert thousands into a string forma: ".XXX"
  # if the number of thousands happens to be a multiple
  # of 100, we assume that we only have 0.1 second precision,
  # and thus we only print ".X"
  def thousands_string
    if thousands == 0
      # print no thousands
      ""
    else
      if thousands % 100 == 0
        ".#{(thousands / 100)}"
      else
        ".#{thousands.to_s.rjust(3, '0')}"
      end
    end
  end

  def hours_minutes_string
    hours = minutes / 60
    if hours > 0
      remaining_minutes = minutes % 60
      "#{hours}:#{remaining_minutes.to_s.rjust(2, '0')}"
    else
      "#{minutes}"
    end
  end

  def seconds_string
    seconds.to_s.rjust(2, "0")
  end

  def full_time
    return unless minutes && seconds && thousands
    "#{hours_minutes_string}:#{seconds_string}#{thousands_string}"
  end
end
