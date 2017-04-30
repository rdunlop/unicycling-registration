class Importers::HeatLaneLifImporter < Importers::BaseImporter
  def process(file, heat, processor)
    return false unless valid_file?(file)

    raw_data = processor.extract_file(file)
    raise StandardError.new("Competition not set for lane assignments") unless @competition.uses_lane_assignments?
    self.num_rows_processed = 0
    self.errors = nil
    begin
      HeatLaneResult.transaction do
        raw_data.each do |raw|
          input_row = processor.process_row(raw)

          result = HeatLaneResult.new(
            entered_by: @user,
            entered_at: DateTime.current,
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
      @errors = invalid
      return false
    end
    true
  end
end
