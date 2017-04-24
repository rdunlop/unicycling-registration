class Importers::WaveUpdater < Importers::BaseImporter
  def process(file, processor)
    return false unless valid_file?(file)

    rows = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil

    current_row = nil
    begin
      TimeResult.transaction do
        rows.each do |row|
          row_hash = processor.process_row(row)
          competitor = competition.competitors.where(lowest_member_bib_number: row_hash[:bib_number]).first
          raise "Unable to find competitor #{bib_number}" if competitor.nil?
          competitor.update_attribute(:wave, row_hash[:wave])
          self.num_rows_processed += 1
        end
      end
    rescue ActiveRecord::RecordInvalid, Exception => invalid
      @errors = "#{invalid} -> Original: #{current_row.bib_number} #{current_row.raw}"
      return false
    end
  end
end
