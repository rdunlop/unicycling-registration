class Importers::HeatLaneLifImporter < Importers::CompetitionDataImporter
  def process(heat, processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    raw_data = processor.file_contents
    self.num_rows_processed = 0
    @errors = []
    begin
      HeatLaneResult.transaction do
        raw_data.each do |raw|
          input_row = processor.process_row(raw)

          result = HeatLaneResult.new(
            entered_by: @user,
            entered_at: Time.current,
            heat: heat,
            lane: input_row[:lane],
            raw_data: raw,
            competition: @competition,
            minutes: input_row[:minutes],
            seconds: input_row[:seconds],
            thousands: input_row[:thousands],
            status: input_row[:status]
          )
          if result.save!
            self.num_rows_processed += 1
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors << invalid.message
      return false
    end
    true
  end
end
