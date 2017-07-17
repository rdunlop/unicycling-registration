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

    results = []
    File.open(upload_file, 'r:UTF-8') do |f|
      f.each do |line|
        row = convert_line_to_array(line)
        results << row
      end
    end
    results
  end

  def convert_line_to_array(line)
    CSV.parse_line(line, col_sep: separator)
  rescue ArgumentError
    raise CSV::MalformedCSVError.new("Unable to parse line")
  end
end
