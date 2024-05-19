class Importers::Parsers::ImportedRegistrant < Importers::Parsers::Base
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

    birthday = Date.strptime(row[4], "%Y/%m/%d") if row[4].present?
    {
      bib_number: row[0],
      first_name: row[1],
      last_name: row[2],
      age: row[3],
      birthday: birthday,
      club: row[5]
    }
  end
end
