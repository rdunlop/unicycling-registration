class Importers::TwoAttemptEntryCsvImporter < Importers::BaseImporter
  # Create TwoAttemptEntry records from a file.
  def process(file, start_times)
    return false unless valid_file?(file)

    # FOR EXCEL DATA:
    raw_data = Importers::CsvExtractor.new(file).extract_csv
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    TwoAttemptEntry.transaction do
      raw_data.each do |raw|
        # 101,1,30,0,,10,45,0,
        # 102,2,30,239,DQ,11,0,0,
        status_1 = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[4])
        status_2 = Importers::StatusTranslation::DqOrDnfOnly.translate(raw[8])
        entry = TwoAttemptEntry.new(
          competition: competition,
          user: user,
          bib_number: raw[0],
          minutes_1: raw[1],
          seconds_1: raw[2],
          thousands_1: raw[3],
          status_1: status_1,

          minutes_2: raw[5],
          seconds_2: raw[6],
          thousands_2: raw[7],
          status_2: status_2,
          is_start_time: is_start_time
        )
        if entry.save!
          self.num_rows_processed += 1
        end
      end
    end

  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end
end
