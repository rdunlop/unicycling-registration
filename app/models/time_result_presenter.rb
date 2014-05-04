class TimeResultPresenter

  attr_accessor :time_in_thousands, :minutes, :seconds, :thousands

  def initialize(time_in_thousands)
    @thousands = time_in_thousands % 1000
    seconds_remaining = (time_in_thousands - @thousands) / 1000
    @seconds = seconds_remaining % 60
    @minutes = (seconds_remaining - @seconds) / 60
  end

  def thousands_string
    if thousands == 0
      # print no thousands
      ""
    else
      if thousands % 100 == 0
        thousands_string = ".#{(thousands / 100).to_s}"
      else
        thousands_string = ".#{thousands.to_s.rjust(3,"0")}"
      end
    end
  end

  def hours_minutes_string
    hours = minutes / 60
    if hours > 0
      remaining_minutes = minutes % 60
      "#{hours}:#{remaining_minutes.to_s.rjust(2,"0")}"
    else
      "#{minutes}"
    end
  end

  def seconds_string
    seconds.to_s.rjust(2, "0")
  end

  def full_time
    "#{hours_minutes_string}:#{seconds_string}#{thousands_string}"
  end
end
