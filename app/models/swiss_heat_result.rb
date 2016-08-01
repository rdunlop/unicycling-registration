require 'csv'

# Convert a file formatted like:
# 3 00:00:13.973  277 1 Monika Sveistrup  "0-10 20"" Female, 20"" Wheel"  Female          00:00:00.186
# 5 00:00:14.302  660 2 Eva Maria Prader  "0-10 20"" Female, 20"" Wheel"  Female          00:00:00.515
class SwissHeatResult
  # returns an array of SwissHeatResult objects
  def self.from_file(file, heat)
    # Duplicated from Upload.rb
    if file.respond_to?(:tempfile)
      upload_file = file.tempfile
    else
      upload_file = file
    end

    results = []
    File.open(upload_file, 'r:ISO-8859-1') do |f|
      f.each do |line|
        results << from_string(line, heat)
      end
    end
    results
  end

  # Create a SwissHeatResult from a single line of text (separated by tabs)
  def self.from_string(string, heat)
    array = CSV.parse_line(string, col_sep: "\t")
    new(heat, array[2], array[3], array[1])
  end

  attr_accessor :bib_number, :heat, :lane, :minutes, :seconds, :thousands
  attr_accessor :status, :status_description
  attr_accessor :raw

  # Create a SwissHeatResult from 3 strings
  def initialize(heat, bib_number, lane, time)
    @heat = heat.to_i
    @bib_number = bib_number.to_i
    @lane = lane.to_i
    @raw = time
    process_time(time)
  end

  def process_time(full_time)
    if disqualification?(full_time)
      self.status = disqualified_status(full_time)
      self.status_description = disqualification_description(full_time)
      self.minutes = 0
      self.seconds = 0
      self.thousands = 0
    else
      time_result = TimeParser.new(full_time).result

      self.status = "active"
      self.status_description = nil
      self.minutes = time_result[:minutes]
      self.seconds = time_result[:seconds]
      self.thousands = time_result[:thousands]
    end
  end

  def disqualification?(full_time)
    disqualified_status(full_time).present?
  end

  def disqualified_status(full_time)
    case full_time.downcase
    when "gestürzt", "scratched", "nicht am start", "disq. rot", "disq. rot agh", "disqualifiziert", "disq. blau", "nicht im ziel"
      "DQ"
    end
  end

  def disqualification_description(full_time)
    case full_time.downcase
    when "gestürzt"
      "Dismount"
    when "scratched"
      "Restart"
    when "nicht am start"
      "DNS"
    when "disq. rot"
      "False Start"
    when "disq. rot agh"
      "Lane"
    when "disqualifiziert"
    when "disq. blau"
      "5m Line"
    when "vicht im ziel"
      "DNF"
    end
  end
end
