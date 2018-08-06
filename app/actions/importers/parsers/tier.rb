class Importers::Parsers::Tier < Importers::Parsers::Base
  def extract_file
    contents = Importers::CsvExtractor.new(file).extract_csv
    contents.drop(1) # skip header row
  end

  def validate_contents
    if file_contents.first.count < 3
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(row)
    return nil if row[0].nil? && row[1].nil?

    {
      bib_number: row[0],
      tier_number: row[1],
      tier_description: row[2]
    }
  end
end
