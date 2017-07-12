class Importers::Parsers::Wave < Importers::Parsers::Base
  def extract_file
    contents = Importers::CsvExtractor.new(file).extract_csv
    contents.drop(1) # skip header row
  end

  def validate_contents
    if file_contents.first.count < 2
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(row)
    return nil if row[0].nil? && row[1].nil?

    {
      bib_number: row[0],
      wave: row[1]
    }
  end
end
