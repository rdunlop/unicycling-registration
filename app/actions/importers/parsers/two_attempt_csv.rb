class Importers::Parsers::TwoAttemptCsv < Importers::Parsers::Base
  attr_reader :results_displayer

  def initialize(file, results_displayer)
    super(file)
    @results_displayer = results_displayer
  end

  def extract_file
    Importers::CsvExtractor.new(file).extract_csv
  end

  def num_columns
    # Bib Number + ((Status + fields) * 2)
    1 + ((1 + results_displayer.form_label_symbols.count) * 2)
  end

  def validate_contents
    if file_contents.first.count < 9
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(raw)
    # 101,,1,30,0,,10,45,0
    # 102,DQ,2,30,239,,11,0,0

    result = {
      bib_number: raw[0],
      first_attempt: {},
      second_attempt: {}
    }
    column = 1

    status_1 = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[column])
    column += 1
    result[:first_attempt][:status] = status_1

    column = 2
    results_displayer.form_label_symbols.each do |symbol|
      result[:first_attempt][symbol] = raw[column]
      column += 1
    end

    status_2 = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[column])
    column += 1
    result[:second_attempt][:status] = status_2

    results_displayer.form_label_symbols.each do |symbol|
      result[:second_attempt][symbol] = raw[column]
      column += 1
    end

    result
  end
end
