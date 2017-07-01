class Importers::SwissResultImporter < Importers::CompetitionDataImporter
  # Create ImportResult records from a file.
  def process(heat, processor, heats: true)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    rows = processor.file_contents
    self.num_rows_processed = 0
    @errors = []

    current_row = nil
    begin
      TimeResult.transaction do
        rows.each do |row|
          current_row = row
          row_hash = processor.process_row(row)

          heat_lane_result = nil
          if heats
            heat_lane_result = create_heat_lane_result(row_hash, heat)
          end
          create_time_result(row_hash, heat_lane_result)

          self.num_rows_processed += 1
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors << "#{invalid.message} -> current row: #{current_row}"
      return false
    end
  end

  private

  def create_heat_lane_result(row_hash, heat)
    heat_lane_result = HeatLaneResult.new(
      competition: competition,
      heat: heat,
      lane: row_hash[:lane],
      status: row_hash[:status],
      minutes: row_hash[:minutes],
      seconds: row_hash[:seconds],
      thousands: row_hash[:thousands],
      raw_data: row_hash[:raw_time],
      entered_at: DateTime.current,
      entered_by: @user
    )
    heat_lane_result.save!
    heat_lane_result
  end

  def create_time_result(row_hash, heat_lane_result)
    competitor = FindCompetitorForCompetition.new(row_hash[:bib_number], competition).competitor
    result = TimeResult.new(
      competitor: competitor,
      status: row_hash[:status],
      status_description: row_hash[:status_description],
      minutes: row_hash[:minutes],
      seconds: row_hash[:seconds],
      thousands: row_hash[:thousands],
      is_start_time: false,
      entered_at: DateTime.current,
      entered_by: @user,
      preliminary: true,
      heat_lane_result: heat_lane_result
    )
    result.save!
  end
end
