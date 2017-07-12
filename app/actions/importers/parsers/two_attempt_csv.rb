class Importers::Parsers::TwoAttemptCsv < Importers::Parsers::Base
  def extract_file
    Importers::CsvExtractor.new(file).extract_csv
  end

  def validate_contents
    if file_contents.first.count < 9
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(raw)
    # 101,1,30,0,,10,45,0,
    # 102,2,30,239,DQ,11,0,0,
    status_1 = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[4])
    status_2 = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[8])
    {
      bib_number: raw[0],
      minutes_1: raw[1],
      seconds_1: raw[2],
      thousands_1: raw[3],
      status_1: status_1,

      minutes_2: raw[5],
      seconds_2: raw[6],
      thousands_2: raw[7],
      status_2: status_2
    }
  end
end
