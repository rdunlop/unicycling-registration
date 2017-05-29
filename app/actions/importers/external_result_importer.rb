class Importers::ExternalResultImporter < Importers::BaseImporter
  def process(file, processor)
    return false unless valid_file?(file)

    # FOR EXCEL DATA:
    raw_data = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil
    ExternalResult.transaction do
      raw_data.each do |raw|
        if build_and_save_imported_result(processor.process_row(raw), @user, @competition)
          self.num_rows_processed += 1
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end

  # from CSV to import_result
  def build_and_save_imported_result(row_hash, user, competition)
    ExternalResult.preliminary.create(
      competitor: CompetitorFinder.new(competition).find_by(bib_number: row_hash[:bib_number]),
      points: row_hash[:points],
      details: row_hash[:details],
      status: row_hash[:status],
      entered_at: DateTime.current,
      entered_by: user
    )
  end
end
