class Importers::TwoAttemptEntryImporter < Importers::CompetitionDataImporter
  def process(start_times, processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    raw_data = processor.file_contents
    self.num_rows_processed = 0
    @errors = []
    is_start_time = start_times || false
    TwoAttemptEntry.transaction do
      raw_data.each do |raw|
        row_hash = processor.process_row(raw)
        next if row_hash.nil? # different than ImportResultImporter
        if build_and_save_imported_result(row_hash, @user, @competition, is_start_time)
          self.num_rows_processed += 1
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors << invalid.message
    false
  end

  # Public: Create an ImportResult object.
  # Throws an exception if not valid
  def build_and_save_imported_result(hash, user, competition, is_start_time)
    TwoAttemptEntry.create!(
      hash.merge(
        is_start_time: is_start_time,
        competition: competition,
        user: user
      )
    )
  end
end
