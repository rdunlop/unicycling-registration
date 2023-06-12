class Importers::TierUpdater < Importers::CompetitionDataImporter
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
        rows.each do |row|
          row_hash = processor.process_row(row)
          competitor = competition.competitors.where(lowest_member_bib_number: row_hash[:bib_number]).first

          if competitor.nil?
            @errors << "Unable to find competitor #{row_hash[:bib_number]}"
            raise ActiveRecord::Rollback
          end

          competitor.update(tier_number: row_hash[:tier_number], tier_description: row_hash[:tier_description])
          self.num_rows_processed += 1
        end
      end
    rescue ActiveRecord::RecordInvalid, RuntimeError => e
      @errors << "Error #{e.message}"
      false
    end
  end
end
