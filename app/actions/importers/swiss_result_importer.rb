class Importers::SwissResultImporter < Importers::BaseImporter
  # Create ImportResult records from a file.
  def process(file, heat, processor)
    return false unless valid_file?(file)

    swiss_results = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil

    current_row = nil
    begin
      TimeResult.transaction do
        rows.each do |row|
          current_row = row
          row_hash = processor.process_row(row)
          process_single_swiss_result(row_hash, row, heat)
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = "#{invalid} -> Original: #{current_row.bib_number} #{current_row.raw}"
      return false
    end
  end

  private

  def process_single_swiss_result(row_hash, _raw, heat)
    competitor = FindCompetitorForCompetition.new(row_hash[:bib_number], competition).competitor

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
    if result.save!
      self.num_rows_processed += 1
    end
  end
end
