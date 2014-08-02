require 'csv'
class Upload

  def initialize(separator = ',')
    @sep = separator
  end

  def extract_csv(file)
    if file.respond_to?(:tempfile)
      upload_file = file.tempfile
    else
      upload_file = file
    end

    results = []
    File.open(upload_file, 'r:ISO-8859-1') do |f|
      f.each do |line|
        row = CSV.parse_line (line)
        results << row
      end
    end
    results
  end

  def convert_line_to_array(line)
    CSV.parse_line(line, col_sep: @sep)
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

  def convert_timing_csv_to_hash(arr)
    results = {}

    results[:bib] = arr[1].to_i

    full_time = arr[4]
    convert_full_time_to_hash(results, full_time)

    results
  end

  private

  def convert_full_time_to_hash(results, full_time)
   if full_time.index(":").nil?
      # no minutes
      results[:minutes] = 0
      seconds_and_hundreds = full_time
    else
      results[:minutes] = full_time[0..(full_time.index(":")-1)].to_i
      seconds_and_hundreds = full_time[full_time.index(":")+1..-1]
    end

    index = seconds_and_hundreds.index(".")
    results[:seconds] = seconds_and_hundreds[0..(index-1)].to_i

    thous = seconds_and_hundreds[(index+1)..-1]
    if thous.length == 1
      results[:thousands] = thous.to_i * 100
    else
      results[:thousands] = thous.to_i
    end
  end
end
