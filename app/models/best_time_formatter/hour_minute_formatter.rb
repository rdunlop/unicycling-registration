class BestTimeFormatter::HourMinuteFormatter
  def self.hint
    "h:mm"
  end

  def self.valid?(string)
    numbers = string.split(":")
    return false unless numbers.count == 2
    to_string(from_string(string)) == string
  end

  # Convert from a string "10:59" to hundreds (65900)
  def self.from_string(string)
    hours, minutes = string.split(":").map(&:to_i).map(&:abs)
    seconds = (hours * 60 * 60) + (minutes * 60)
    seconds * 100
  end

  # Convert from hundreds (65900) to a string "10:59"
  def self.to_string(int)
    return "" if int.nil?

    seconds = int / 100
    minutes = seconds / 60
    hours = minutes / 60
    remaining_minutes = minutes % 60
    format("%d:%02d", hours, remaining_minutes)
  end
end
