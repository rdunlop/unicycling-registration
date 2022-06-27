class Importers::UniTimerImporter < Importers::CompetitionDataImporter
  def process(start_times, processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    raw_data = processor.file_contents
    self.num_rows_processed = 0
    @errors = []
    is_start_time = start_times || false

    # Also includes :raw element with the original contents
    filtered_data_hashes = []
    raw_data.each do |raw|
      processed_hash = processor.process_row(raw)
      if processed_hash[:clear]
        filtered_data_hashes.pop
      else
        filtered_data_hashes.push(processed_hash.merge(raw: raw))
      end
    end

    ImportResult.transaction do
      filtered_data_hashes.each do |hash|
        if build_and_save_imported_result(hash, hash[:raw], @user, @competition, is_start_time)
          self.num_rows_processed += 1
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    false
  end

  # Public: Create an ImportResult object.
  # Throws an exception if not valid
  def build_and_save_imported_result(hash, raw, user, competition, is_start_time)
    ImportResult.create!(
      hash.slice(*ImportResult.column_names.map(&:to_sym)).merge(
        raw_data: convert_array_to_string(raw),
        user: user,
        competition: competition,
        is_start_time: is_start_time,
        number_of_penalties: hash[:fault] ? 1 : 0
      )
    )
  end

  private

  def convert_array_to_string(arr)
    str = "["
    arr.each do |el|
      str += "#{el},"
    end
    str += "]"
    str
  end
end
