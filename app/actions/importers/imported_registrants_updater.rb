class Importers::ImportedRegistrantsUpdater < Importers::BaseImporter
  def process(processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    rows = processor.file_contents
    self.num_rows_processed = 0
    @errors = []

    begin
      ImportedRegistrant.transaction do
        rows.each do |row|
          row_hash = processor.process_row(row)
          reg = ImportedRegistrant.find_by(bib_number: row_hash[:bib_number])

          reg = ImportedRegistrant.new(bib_number: row_hash[:bib_number]) if reg.nil?

          reg.first_name = row_hash[:first_name]
          reg.last_name = row_hash[:last_name]
          reg.age = row_hash[:age].presence
          reg.birthday = row_hash[:birthday]
          reg.club = row_hash[:club]

          if reg.save
            @errors << "Unable to save record for #{row_hash[:bib_number]}"
            self.num_rows_processed += 1
          else
            raise ActiveRecord::Rollback
          end
        end
      end
    rescue ActiveRecord::RecordInvalid, RuntimeError => e
      @errors << "Error #{e.message}"
      false
    end
  end
end
