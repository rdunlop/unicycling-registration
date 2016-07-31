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

  attr_accessor :bib_number, :heat, :lane, :minutes, :seconds, :thousands, :status

  # Create a SwissHeatResult from 3 strings
  def initialize(heat, bib_number, lane, time)
    @heat = heat.to_i
    @bib_number = bib_number.to_i
    @lane = lane.to_i
    process_time(time)
  end

  def process_time(full_time)
    if disqualification?(full_time)
      self.status = disqualified_status(full_time)
      self.minutes = 0
      self.seconds = 0
      self.thousands = 0
    else
      time_result = TimeParser.new(full_time).result

      self.status = "active"
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
    when "gestürzt", "scratched", "nicht am start", "disq. rot", "disqualifiziert", "disq. blau"
      "DQ"
    end
  end
  #   return false unless valid_file?(file)

  #   upload = Upload.new("\t")
  #   raw_data = upload.extract_csv(file)
  #   raise StandardError.new("Competition not set for lane assignments") unless @competition.uses_lane_assignments?
  #   self.num_rows_processed = 0
  #   self.errors = nil
  #   process_raw_rows(heat, raw_data)
  # end

  # def process_raw_rows(heat, raw_data)
  #   begin
  #     HeatLaneResult.transaction do
  #       raw_data.each do |raw|
  #         process_single_row(heat, raw)
  #       end
  #     end
  #   rescue ActiveRecord::RecordInvalid => invalid
  #     @errors = invalid
  #     return false
  #   end
  #   true
  # end

  # def process_single_row(heat, raw)
  #   row_hash = convert_to_hash(raw)
  #   lane = row_hash[:lane]

  #   result = HeatLaneResult.new(
  #     entered_by: @user,
  #     entered_at: DateTime.current,
  #     heat: heat,
  #     lane: lane,
  #     raw_data: raw,
  #     competition: @competition,
  #     minutes: row_hash[:minutes],
  #     seconds: row_hash[:seconds],
  #     thousands: row_hash[:thousands],
  #     status: (row_hash[:disqualified] ? "DQ" : "active")
  #   )
  #   if result.save!
  #     self.num_rows_processed += 1
  #   end
  # end
end
