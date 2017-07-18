require 'csv'

class Importers::CsvExtractor
  attr_reader :file, :separator

  def initialize(file, separator: ',')
    @file = file
    @separator = separator
  end

  def extract_csv
    if file.respond_to?(:tempfile)
      upload_file = file.tempfile
    else
      upload_file = file
    end

    CSV.read(upload_file, encoding: "UTF-8", col_sep: separator)
  rescue ArgumentError
    raise CSV::MalformedCSVError.new("Unable to parse line")
  end
end
