class Importers::ImportResultCsvImporter
  attr_reader :read_num_laps

  def initialize(read_num_laps: false)
    @read_num_laps = read_num_laps
  end

  def extract_file(file)
    Importers::CsvExtractor.new(file).extract_csv
  end

  def process_row(row)
    time_entry = row[4]

    num_laps = read_num_laps ? row[5] : nil
    status = Importers::StatusTranslation::DqOrDnfOnly.translate(time_entry)
    {
      bib_number: row[0],
      minutes: row[1],
      seconds: row[2],
      thousands: row[3],
      number_of_laps: num_laps,
      status: status
    }
  end
end
