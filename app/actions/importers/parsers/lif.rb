class Importers::Parsers::Lif < Importers::Parsers::Base
  def extract_file
    data = Importers::CsvExtractor.new(file).extract_csv
    data.drop(1) # drop header row
  end

  def validate_contents
    if file_contents.first.count < 7
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(raw)
    lif_hash = convert_lif_to_hash(raw)

    {
      lane: lif_hash[:lane],
      minutes: lif_hash[:minutes],
      seconds: lif_hash[:seconds],
      thousands: lif_hash[:thousands],
      status: (lif_hash[:disqualified] ? "DQ" : "active")
    }
  end

  def convert_lif_to_hash(arr)
    results = {}

    results[:lane] = arr[2]

    full_time = arr[6].to_s
    # TODO: Extract this into a StatusTranslation
    if full_time == "DQ" || arr[0] == "DQ" || arr[0] == "DNS" || arr[0] == "DNF"
      results[:disqualified] = true
      results[:minutes] = 0
      results[:seconds] = 0
      results[:thousands] = 0
    else
      results[:disqualified] = false

      time_result = TimeParser.new(full_time).result
      results[:minutes] = time_result[:minutes]
      results[:seconds] = time_result[:seconds]
      results[:thousands] = time_result[:thousands]
    end
    results
  end
end
