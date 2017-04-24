class Importers::Parsers::Wave
  def extract_file(file)
    contents = Importers::CsvExtractor.new(file).extract_csv
    contents.drop(1) # skip header row
  end

  def process_row(row)
    return nil if row[0].nil? && row[1].nil?

    {
      bib_number: row[0],
      wave: row[1]
    }
  end
end
