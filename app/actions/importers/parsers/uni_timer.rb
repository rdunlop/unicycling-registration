class Importers::Parsers::UniTimer < Importers::Parsers::Base
  def extract_file
    Importers::CsvExtractor.new(file).extract_csv
  end

  def validate_contents
    if file_contents.first.count < 4
      @errors << "Not enough columns. Are you sure this is a comma-separated file?"
    end
  end

  def process_row(raw)
    if raw == ["CLEAR_PREVIOUS"]
      return {
        clear: true
      }
    end

    {
      bib_number: raw[0].to_s,
      minutes: raw[1].to_i,
      seconds: raw[2].to_i,
      thousands: raw[3].to_i,
      status: "active",
      fault: raw.length > 4 ? raw[4] == "FAULT" : false
    }
  end
end
