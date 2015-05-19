require 'csv'
class CsvExtractor
  attr_accessor :file

  def initialize(file)
    @file = file
  end

  def extract_csv
    if file.respond_to?(:tempfile)
      upload_file = file.tempfile
    else
      upload_file = file
    end

    results = []
    CSV.foreach(upload_file, headers: true) do |row|
      results << row.to_hash
    end
    results
  end
end
