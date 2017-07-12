class Importers::ExternalResultImporter < Importers::CompetitionDataImporter
  def process(processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    # FOR EXCEL DATA:
    raw_data = processor.file_contents
    self.num_rows_processed = 0
    @errors = []
    ExternalResult.transaction do
      raw_data.each do |raw|
        if build_and_save_imported_result(processor.process_row(raw), @user, @competition)
          self.num_rows_processed += 1
        else
          raise ActiveRecord::Rollback
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors << invalid.message
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
  rescue ActiveRecord::RecordNotFound
    @errors << "Unable to find registrant (#{row_hash})"
    return false
  end
end
