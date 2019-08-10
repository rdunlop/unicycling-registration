class BestTimeFormatter::CentimeterFormatter
  MAX_VALID_DISTANCE = 6_00 # 6 meters

  def self.hint
    "cm"
  end

  def self.valid?(string)
    return false unless string.to_i.to_s == string

    return false if string.to_i.negative?

    string.to_i <= MAX_VALID_DISTANCE
  end

  # Convert from a string "10" to an integer (10)
  def self.from_string(string)
    string.to_i
  end

  # Convert from a number (10) to a string "10"
  def self.to_string(int)
    int.to_s
  end
end
