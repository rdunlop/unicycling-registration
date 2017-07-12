class Importers::Parsers::ExternalResultCsv < Importers::Parsers::Base
  def extract_file
    Importers::CsvExtractor.new(file).extract_csv
  end

  def validate_contents
    if file_contents.first.count < 2 # column 3 is optional
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(raw)
    {
      bib_number: raw[0],
      points: raw[1],
      details: raw[2],
      status: "active"
    }
  end
end
