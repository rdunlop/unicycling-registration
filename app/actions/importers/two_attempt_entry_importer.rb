class Importers::TwoAttemptEntryImporter < Importers::BaseImporter
  def process(file, start_times, processor)
    return false unless valid_file?(file)

    raw_data = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil
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
    @errors = invalid
    return false
  end

  # Public: Create an ImportResult object.
  # Throws an exception if not valid
  def build_and_save_imported_result(hash, user, competition, is_start_time)
    TwoAttemptEntry.create!(
      bib_number: hash[:bib_number],
      minutes_1: hash[:minutes_1],
      seconds_1: hash[:seconds_1],
      thousands_1: hash[:thousands_1],
      status_1: hash[:status_1],

      minutes_2: hash[:minutes_2],
      seconds_2: hash[:seconds_2],
      thousands_2: hash[:thousands_2],
      status_2: hash[:status_2],

      is_start_time: is_start_time,
      competition: competition,
      user: user
    )
  end
end
