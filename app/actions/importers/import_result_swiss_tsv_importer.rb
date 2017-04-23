class Importers::ImportResultSwissTsvImporter
  def initialize(competition, user)
    @importer = Importers::ImportResultImporter.new(competition, user)
  end

  def process(file, start_times)
    @importer.process(file, start_times, self)
  end

  def extract_file(file)
    Importers::CsvExtractor.new(file, "\t").extract_csv
  end

  # 3 00:00:13.973  277 1 Monika Sveistrup  "0-10 20"" Female, 20"" Wheel"  Female          00:00:00.186
  def process_row(row)
    time_entry = row[1]
    # XXX combine this with the SwissHeatResult class...same logic, no?
    time_result = TimeParser.new(time_entry).result

    status = Importers::StatusTranslation::DqOrDnfOnly.translate(time_entry)
    {
      bib_number: row[2],
      minutes: time_result[:minutes],
      seconds: time_result[:seconds],
      thousands: time_result[:thousands],
      number_of_laps: nil,
      status: status
    }
  end
end
