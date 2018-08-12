class TimeResultPresenter
  attr_accessor :minutes, :seconds, :thousands
  attr_reader :display_hours, :display_thousands, :display_hundreds

  def self.from_thousands(time_in_thousands, data_entry_format: nil)
    thousands = time_in_thousands % 1000
    seconds_remaining = (time_in_thousands - thousands) / 1000
    seconds = seconds_remaining % 60
    minutes = (seconds_remaining - seconds) / 60
    new(minutes, seconds, thousands, data_entry_format: data_entry_format)
  end

  def initialize(minutes, seconds, thousands, data_entry_format: nil)
    @minutes = minutes.to_i
    @seconds = seconds.to_i
    @thousands = thousands.to_i
    if data_entry_format.nil?
      data_entry_format = OpenStruct.new(hours?: false, thousands?: true, hundreds?: false)
    end
    @display_hours = data_entry_format.hours?
    @display_hundreds = data_entry_format.hundreds?
    @display_thousands = data_entry_format.thousands?
  end

  def full_time
    return unless minutes.positive? || seconds.positive? || thousands.positive?
    "#{hours_minutes_string}:#{seconds_string}#{thousands_string}"
  end

  private

  # convert thousands into a string format: ".XXX" or ".XX" or ""
  # we display the precision based on the competition configuration
  def thousands_string
    if display_thousands
      ".#{pad(thousands, 3)}"
    elsif display_hundreds
      ".#{pad((thousands / 10.0).round, 2)}"
    else
      ""
    end
  end

  def hours_minutes_string
    hours = minutes / 60
    if hours.positive? || display_hours
      remaining_minutes = minutes % 60
      "#{hours}:#{pad(remaining_minutes, 2)}"
    else
      pad(minutes, 2)
    end
  end

  def seconds_string
    pad(seconds, 2)
  end

  def pad(number, decimals)
    number.to_s.rjust(decimals, "0")
  end
end
