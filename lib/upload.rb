require 'csv'
class Upload

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
      results[:thousands] = seconds_and_hundreds[(index+1)..-1].to_i
    end
    results
  end

  # CSV File exported from UCP
  def process_csv_upload(params)
    n=0
    if params[:dump][:file].respond_to?(:tempfile)
        upload_file = params[:dump][:file].tempfile
    else
        upload_file = params[:dump][:file]
    end

    File.open(upload_file, 'r:ISO-8859-1') do |f|
     f.each do |line|
      row = CSV.parse_line (line)
      # sample rows:
      #1,"Robin","Dunlop",1,29,"Male"
      #2,"Connie","Cotter",1,46,"Female"
      #3,"Ann","O'Brien",0,53,"Female"
      c=Registrant.new
      c.initialize_from_array(row)
      if c.save
        n=n+1
      end
     end
    end
    n
  end
end
