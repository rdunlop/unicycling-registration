class Importers::Parsers::Swiss
  def extract_file(file)
    Importers::CsvExtractor.new(file, separator: "\t").extract_csv
  end

  # Convert a file formatted like:
  # 3 00:00:13.973  277 1 Monika Sveistrup  "0-10 20"" Female, 20"" Wheel"  Female          00:00:00.186
  # 5 00:00:14.302  660 2 Eva Maria Prader  "0-10 20"" Female, 20"" Wheel"  Female          00:00:00.515
  def process_row(row)
    bib_number = row[2].to_i
    lane = row[3].to_i
    raw_time = row[1]
    row_hash = process_time(raw_time)
    row_hash[:bib_number] = bib_number
    row_hash[:lane] = lane
    row_hash[:raw_time] = raw_time
    row_hash
  end

  def process_time(full_time)
    if disqualification?(full_time)
      {
        status: disqualified_status(full_time),
        status_description: disqualification_description(full_time),
        minutes: 0,
        seconds: 0,
        thousands: 0
      }
    else
      time_result = TimeParser.new(full_time).result

      {
        status: "active",
        status_description: nil,
        minutes: time_result[:minutes],
        seconds: time_result[:seconds],
        thousands: time_result[:thousands]
      }
    end
  end

  def disqualification?(full_time)
    disqualified_status(full_time) == "DQ"
  end

  def disqualified_status(full_time)
    Importers::StatusTranslation::Swiss.translate(full_time)
  end

  def disqualification_description(full_time)
    Importers::StatusTranslation::Swiss.dq_description(full_time)
  end
end
