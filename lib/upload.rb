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
        row = convert_line_to_array(line)
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

    full_time = find_full_time(arr)

    convert_full_time_to_hash(results, full_time)

    results
  end

  def is_blank_line(arr)
    find_full_time(arr) == "-"
  end

  private

  def convert_full_time_to_hash(results, ft)
    if ft.index(":").nil?
      # no minutes
      results[:minutes] = 0
      seconds_and_hundreds = ft
    else
      split_by_minutes = ft.split(':')
      if split_by_minutes.length == 3
        hours = split_by_minutes[0].to_i
        minutes = split_by_minutes[1].to_i
        results[:minutes] = minutes + (hours * 60)
      else
        results[:minutes] = split_by_minutes[0].to_i #full_time[0..(full_time.index(":")-1)].to_i
      end
      seconds_and_hundreds = split_by_minutes[-1] # full_time[full_time.index(":")+1..-1]
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

  def find_full_time(arr)
    if arr.count == 11
      full_time = arr[5]
    else
      full_time = arr[6]
    end
  end
end
