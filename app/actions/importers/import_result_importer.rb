class Importers::ImportResultImporter < Importers::BaseImporter
  def process(file, start_times, processor)
    return false unless valid_file?(file)

    raw_data = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    ImportResult.transaction do
      raw_data.each do |raw|
        if build_and_save_imported_result(processor.process_row(raw), raw, @user, @competition, is_start_time)
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
  def build_and_save_imported_result(hash, raw, user, competition, is_start_time)
    ImportResult.create!(
      bib_number: hash[:bib_number],
      minutes: hash[:minutes],
      seconds: hash[:seconds],
      thousands: hash[:thousands],
      number_of_laps: hash[:number_of_laps],
      status: hash[:status],
      raw_data: Upload.new.convert_array_to_string(raw),
      user: user,
      competition: competition,
      is_start_time: is_start_time)
  end
end
