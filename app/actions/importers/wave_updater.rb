class Importers::WaveUpdater < Importers::CompetitionDataImporter
  def process(file, processor)
    return false unless valid_file?(file)

    rows = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil

    begin
      TimeResult.transaction do
        rows.each do |row|
          row_hash = processor.process_row(row)
          competitor = competition.competitors.where(lowest_member_bib_number: row_hash[:bib_number]).first

          if competitor.nil?
            @errors = "Unable to find competitor #{row_hash[:bib_number]}"
            raise ActiveRecord::Rollback
          end

          competitor.update_attribute(:wave, row_hash[:wave])
          self.num_rows_processed += 1
        end
      end
    rescue ActiveRecord::RecordInvalid, RuntimeError => invalid
      @errors = "Error #{invalid}"
      return false
    end
  end
end
