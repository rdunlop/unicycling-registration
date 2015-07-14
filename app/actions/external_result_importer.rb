require 'upload'

class ExternalResultImporter
  attr_accessor :competition, :user, :num_rows_processed, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def process_csv(file)
    upload = Upload.new
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    ExternalResult.transaction do
      raw_data.each do |raw|
        data = upload.convert_array_to_string(raw)
        if ExternalResult.build_and_save_imported_result(raw, data, @user, @competition)
          self.num_rows_processed += 1
        end
      end
    end

  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end

end
