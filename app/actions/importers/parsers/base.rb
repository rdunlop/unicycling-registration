class Importers::Parsers::Base
  attr_accessor :errors
  attr_reader :file, :file_contents

  def initialize(file = nil)
    @file = file
    @errors = []
  end

  # read the file contents
  def file_contents
    @file_contents ||= extract_file
  rescue CSV::MalformedCSVError => error
    @errors << "Unable to read file. Is it it plain-text file? (#{error.message})"
    return false
  end

  def extract_file
    raise "Implemented by subclass" # May add @errors
  end

  def validate_contents
    # can be implemented by child class
  end

  def valid_file?
    if file.blank?
      @errors << "File not found"
      return false
    end

    file_contents # cause extraction
    validate_contents if @errors.none?

    @errors.none?
  end
end
