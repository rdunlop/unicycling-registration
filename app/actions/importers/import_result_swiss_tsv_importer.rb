class Importers::ImportResultSwissTsvImporter < Importers::BaseImporter
  def process(file, start_times)
    return false unless valid_file?(file)

    upload = Upload.new
    # FOR EXCEL DATA:
    raw_data = Importers::CsvExtractor.new(file, "\t").extract_csv
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    ImportResult.transaction do
      raw_data.each do |raw|
        data = upload.convert_array_to_string(raw)
        if build_and_save_imported_result(raw, data, @user, @competition, is_start_time)
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
  def build_and_save_imported_result(raw, raw_data, user, competition, is_start_time)
    status = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[4])

    # TODO: extract this into a place which is controlled more closely by ScoringClass
    num_laps = competition.has_num_laps? ? raw[5] : nil
    ImportResult.create!(
      bib_number: raw[0],
      minutes: raw[1],
      seconds: raw[2],
      thousands: raw[3],
      number_of_laps: num_laps,
      status: status,
      raw_data: raw_data,
      user: user,
      competition: competition,
      is_start_time: is_start_time)
  end
end
