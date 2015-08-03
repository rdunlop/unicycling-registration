require 'upload'

class RaceDataImporter
  attr_accessor :competition, :user, :num_rows_processed, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def process_lif(file, heat)
    upload = Upload.new
    raw_data = upload.extract_csv(file)
    raise StandardError.new("Competition not set for lane assignments") unless @competition.uses_lane_assignments?
    self.num_rows_processed = 0
    self.errors = nil
    raw_data.shift # drop header row
    begin
      HeatLaneResult.transaction do
        raw_data.each do |raw|
          lif_hash = upload.convert_lif_to_hash(raw)
          lane = lif_hash[:lane]

          result = HeatLaneResult.new(
            entered_by: @user,
            entered_at: DateTime.now,
            heat: heat,
            lane: lane,
            raw_data: raw,
            competition: @competition,
            minutes: lif_hash[:minutes],
            seconds: lif_hash[:seconds],
            thousands: lif_hash[:thousands],
            status: (lif_hash[:disqualified] ? "DQ" : "active"),
          )
          if result.save!
            self.num_rows_processed += 1
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = invalid
      return false
    end
    true
  end

  def process_csv(file, start_times)
    upload = Upload.new
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    ImportResult.transaction do
      raw_data.each do |raw|
        data = upload.convert_array_to_string(raw)
        if TimeResult.build_and_save_imported_result(raw, data, @user, @competition, is_start_time)
          self.num_rows_processed += 1
        end
      end
    end

  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end

  def process_chip(file, bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number)
    upload = Upload.new(';', bib_number_column_number, time_column_number, lap_column_number)
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    # drop the first (title) line
    raw_data = raw_data.drop(1)
    begin
      ImportResult.transaction do
        raw_data.each do |raw|
          str = upload.convert_array_to_string(raw)
          next if upload.is_blank_line(raw) || raw.count == 0
          chip_hash = upload.convert_timing_csv_to_hash(raw)
          result = ImportResult.new(
            bib_number: chip_hash[:bib],
            status: chip_hash[:status],
            minutes: chip_hash[:minutes],
            seconds: chip_hash[:seconds],
            number_of_laps: chip_hash[:laps],
            thousands: convert_to_thousands(chip_hash[:thousands].to_i, number_of_decimal_places)
          )
          result.raw_data = str
          result.user = @user
          result.competition = @competition
          result.is_start_time = false
          if result.save!
            self.num_rows_processed += 1
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = invalid
      return false
    end
  end

  def convert_to_thousands(imported_time, number_of_decimal_places)
    case number_of_decimal_places
    when 1
      imported_time # don't convert because of Upload.rb convert_full_time_to_hash has special handling..
    when 2
      imported_time * 10
    when 3
      imported_time * 1
    when 4
      imported_time.round(-1) / 10
    else
      raise "What do you mean?"
    end
  end

  def add_error(lane)
    error_message = "Missing Lane Assignment for Lane #{lane}"
    if errors.nil?
      self.errors = error_message
    else
      self.errors += error_message
    end
  end

end
