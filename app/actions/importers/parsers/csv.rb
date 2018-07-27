class Importers::Parsers::Csv < Importers::Parsers::Base
  attr_reader :results_displayer

  def initialize(file, results_displayer)
    super(file)
    @results_displayer = results_displayer
  end

  def extract_file
    Importers::CsvExtractor.new(file).extract_csv
  end

  def num_columns
    2 + results_displayer.form_label_symbols.count
  end

  def validate_contents
    if file_contents.first.count < num_columns
      @errors << "Not enough columns. Are you sure this is the right format? (comma-separated)"
    end
  end

  def process_row(row)
    time_entry = row[1] # dq column

    status = Importers::StatusTranslation::DqOrDnfOnly.translate(time_entry)
    result = {
      bib_number: row[0],
      status: status
    }

    column = 2
    results_displayer.form_label_symbols.each do |symbol|
      result[symbol] = row[column]
      column += 1
    end

    result
  end
end
