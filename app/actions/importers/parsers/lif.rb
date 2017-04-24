class Importers::Parsers::Lif
  def extract_file(file)
    data = Importers::CsvExtractor.new(file).extract_csv
    data.drop(1) # drop header row
  end

  def process_row(raw)
    lif_hash = Upload.new.convert_lif_to_hash(raw)

    {
      lane: lif_hash[:lane],
      minutes: lif_hash[:minutes],
      seconds: lif_hash[:seconds],
      thousands: lif_hash[:thousands],
      status: (lif_hash[:disqualified] ? "DQ" : "active")
    }
  end
end
