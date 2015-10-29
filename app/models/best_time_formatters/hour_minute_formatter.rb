class HourMinuteFormatter

  def self.hint
    "hh:mm"
  end

  def self.valid?(string)
    string.split(":").count == 2
  end

  def self.from_string(string)
    minutes, seconds = string.split(":").map(&:to_i)
    seconds += minutes * 60
    seconds * 100
  end

  def self.to_string(int)
    return "" if int.nil?

    seconds = int / 100
    minutes = seconds / 60
    seconds = seconds % 60
    "#{minutes}:#{seconds}"
  end
end
