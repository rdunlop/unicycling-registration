require 'upload'

class TwoAttemptEntryCsvImporter
  attr_accessor :competition, :user, :num_rows_processed, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  # Create TwoAttemptEntry records from a file.
  def process(file, start_times)
    upload = Upload.new
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    TwoAttemptEntry.transaction do
      raw_data.each do |raw|
        # 101,1,30,0,,10,45,0,
        # 102,2,30,239,DQ,11,0,0,
        status_1 = (raw[4] == "DQ") ? "DQ" : "active"
        status_2 = (raw[8] == "DQ") ? "DQ" : "active"
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
