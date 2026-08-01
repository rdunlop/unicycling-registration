class Importers::WaveUpdater < Importers::CompetitionDataImporter
  def process(processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    rows = processor.file_contents
    self.num_rows_processed = 0
    @errors = []

    begin
      TimeResult.transaction do
        rows.each_with_index do |row, index|
          row_hash = processor.process_row(row)

          if row_hash.nil?
            @errors << "Error processing row #{index + 1}: #{row.inspect}"
            raise ActiveRecord::Rollback
          end

          competitor = competition.competitors.where(lowest_member_bib_number: row_hash[:bib_number]).first

          if competitor.nil?
            @errors << "Unable to find competitor #{row_hash[:bib_number]} at row #{index + 1}"
            raise ActiveRecord::Rollback
          end

          competitor.update_attribute(:wave, row_hash[:wave])
          self.num_rows_processed += 1
        end
      end
    rescue ActiveRecord::RecordInvalid, RuntimeError => e
      @errors << "Error #{e.message}"
      false
    end
  end
end
