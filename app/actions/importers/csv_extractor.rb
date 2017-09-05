require 'csv'

class Importers::CsvExtractor
  attr_reader :file, :separator

  class ParseError < StandardError
  end

  def initialize(file, separator: ',')
    @file = file
    @separator = separator
  end

  def extract_csv
    if file.respond_to?(:tempfile)
      upload_file = file.tempfile
    elsif file.respond_to?(:file)
      upload_file = file.file
    else
      upload_file = file
    end

    begin
      return attempt_parse(upload_file, "UTF-8")
    rescue ParseError
      # If it fails to parse the file as UTF-8, try again
      begin
        return attempt_parse(upload_file, "ISO-8859-1")
      rescue ParseError
      end
    end

    raise CSV::MalformedCSVError.new("Unable to parse line")
  end

  def attempt_parse(upload_file, encoding)
    CSV.read(upload_file, encoding: encoding, col_sep: separator)
  rescue ArgumentError
    raise ParseError
  end
end
