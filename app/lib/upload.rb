class Upload
  def initialize(separator = ',', bib_number_column_number = 1, time_column_number = nil, laps_column = nil)
    @sep = separator
    @time_column_number = time_column_number
    @bib_number_column_number = bib_number_column_number
    @laps_column = laps_column
  end

  def extract_csv(file)
    Importers::CsvExtractor.new(file, separator: @sep).extract_csv
  end

  def convert_array_to_string(arr)
    str = "["
    arr.each do |el|
      str += "#{el},"
    end
    str += "]"
    str
  end

  def convert_lif_to_hash(arr)
    results = {}

    results[:lane] = arr[2]

    full_time = arr[6].to_s
    if full_time == "DQ" || arr[0] == "DQ" || arr[0] == "DNS" || arr[0] == "DNF"
      results[:disqualified] = true
      results[:minutes] = 0
      results[:seconds] = 0
      results[:thousands] = 0
    else
      results[:disqualified] = false

      convert_full_time_to_hash(results, full_time)
    end
    results
  end

  def convert_timing_csv_to_hash(arr, _time_column_number = nil)
    results = {}

    results[:bib] = arr[@bib_number_column_number].to_i
    results[:laps] = get_laps_count(arr)

    full_time = find_full_time(arr)

    convert_full_time_to_hash(results, full_time)

    results
  end

  def is_blank_line(arr)
    find_full_time(arr) == "-"
  end

  private

  def get_laps_count(arr)
    arr[@laps_column] unless @laps_column.nil?
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

    if arr.count == 11
      arr[5]
    else
      arr[6]
    end
  end
end
