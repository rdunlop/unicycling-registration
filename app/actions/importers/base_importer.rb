class Importers::BaseImporter
  attr_accessor :num_rows_processed, :num_rows_skipped, :errors
  attr_reader :file, :process, :record_creator

  def initialize(file, processor, record_creator)
    @file = file
    @processor = processor
    @record_creator = record_creator
    @num_rows_processed = 0
    @num_rows_skipped = 0
    @errors = nil
  end

  def process
    return false unless valid_file?

    rows = processor.extract_file(file)

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

  private

  def valid_file?
    if file.blank?
      @errors = "File not found"
      return false
    end

    true
  end
end
