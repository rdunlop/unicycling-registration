class Importers::BaseImporter
  attr_accessor :competition, :user, :num_rows_processed, :num_rows_skipped, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def valid_file?(file)
    if file.blank?
      @errors = "File not found"
      return false
    end

    true
  end

  def process_all_rows(file, processor, record_creator)
    return false unless valid_file?(file)

    rows = processor.extract_file(file)
    self.num_rows_processed = 0
    self.num_rows_skipped = 0
    self.errors = nil

    current_row = nil
    TwoAttemptEntry.transaction do
      rows.each do |row|
        current_row = row
        row_hash = processor.process_row(row)
        if row_hash.nil?
          self.num_rows_skipped += 1
          next
        end
        if record_creator.save(row_hash, row)
          self.num_rows_processed += 1
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors = "#{invalid} -> current row: #{current_row}"
    return false
  end
end
