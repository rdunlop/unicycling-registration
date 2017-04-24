class Importers::Parsers::ExternalResultCsv
  def extract_file(file)
    Importers::CsvExtractor.new(file).extract_csv
  end

  def process_row(raw)
    data = Upload.new.convert_array_to_string(raw)

    {
      bib_number: raw[0],
      points: raw[1],
      details: raw[2],
      status: "active"
    }
  end
end
