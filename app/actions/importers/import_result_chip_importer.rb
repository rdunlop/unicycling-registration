class Importers::ImportResultChipImporter < Importers::BaseImporter
  # Create ImportResult records from a file.
  # File Format, separated by ';', includes a blank line.
  def process(file, bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number)
    return false unless valid_file?(file)

    upload = Upload.new(bib_number_column_number, time_column_number, lap_column_number)
    raw_data = Importers::CsvExtractor.new(file, ';').extract_csv
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

  private

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
end
