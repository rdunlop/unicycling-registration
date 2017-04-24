class Importers::Parsers::Chip
  attr_reader :bib_number_column_number, :time_column_number, :number_of_decimal_places, :lap_column_number

  def initialize(bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number)
    @bib_number_column_number = bib_number_column_number
    @time_column_number = time_column_number
    @number_of_decimal_places = number_of_decimal_places
    @lap_column_number = lap_column_number
  end

  def extract_file(file)
    # File Format, separated by ';', includes a blank line.
    raw_data = Importers::CsvExtractor.new(file, separator: ';').extract_csv
    # drop the first (title) line
    raw_data.drop(1)
  end

  def process_row(row)
    upload = Upload.new(bib_number_column_number, time_column_number, lap_column_number)

    chip_hash = upload.convert_timing_csv_to_hash(row)
    {
      bib_number: chip_hash[:bib],
      seconds: chip_hash[:seconds],
      minutes: chip_hash[:minutes],
      thousands: convert_to_thousands(chip_hash[:thousands].to_i, number_of_decimal_places),
      status: chip_hash[:status],
      number_of_laps: chip_hash[:laps]
    }
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
