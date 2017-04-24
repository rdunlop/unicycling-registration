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
    chip_hash = convert_timing_csv_to_hash(row)
    {
      bib_number: chip_hash[:bib],
      seconds: chip_hash[:seconds],
      minutes: chip_hash[:minutes],
      thousands: convert_to_thousands(chip_hash[:thousands].to_i, number_of_decimal_places),
      status: chip_hash[:status],
      number_of_laps: chip_hash[:laps]
    }
  end

  def convert_timing_csv_to_hash(arr)
    results = {}

    results[:bib] = arr[@bib_number_column_number].to_i
    results[:laps] = get_laps_count(arr)

    full_time = find_full_time(arr)

    convert_full_time_to_hash(results, full_time)

    results
  end

  private

  def get_laps_count(arr)
    arr[@lap_column_number] unless @lap_column_number.nil?
  end

  def convert_full_time_to_hash(results, full_time)
    if full_time == "DQ" || full_time == "DSQ"
      results[:status] = "DQ"
    else
      results[:status] = nil
      results.merge!(TimeParser.new(full_time).result)
    end

    results
  end

  def find_full_time(arr)
    return arr[@time_column_number] unless @time_column_number.nil?

    arr[5] # magically choose the 6th column if not specified
  end

  def convert_to_thousands(imported_time, number_of_decimal_places)
    case number_of_decimal_places
    when 1
      # We should multiply "* 100", but we don't, because
      # TimeParser will do this when it finds only a single "thousands" point.
      imported_time
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
