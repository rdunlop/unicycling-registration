class Importers::ExternalResultImporter < Importers::BaseImporter
  def process(file)
    return false unless valid_file?(file)

    upload = Upload.new
    # FOR EXCEL DATA:
    raw_data = Importers::CsvExtractor.new(file).extract_csv
    self.num_rows_processed = 0
    self.errors = nil
    ExternalResult.transaction do
      raw_data.each do |raw|
        data = upload.convert_array_to_string(raw)
        if build_and_save_imported_result(raw, data, @user, @competition)
          self.num_rows_processed += 1
        end
      end
    end

  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end

  # from CSV to import_result
  def build_and_save_imported_result(raw, _raw_data, user, competition)
    ExternalResult.preliminary.create(
      competitor: CompetitorFinder.new(competition).find_by_bib_number(raw[0]),
      points: raw[1],
      details: raw[2],
      status: "active",
      entered_at: DateTime.current,
      entered_by: user)
  end
end
