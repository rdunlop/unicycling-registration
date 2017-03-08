class Importers::SwissResultImporter < Importers::BaseImporter
  # Create ImportResult records from a file.
  def process(file, heat)
    return false unless valid_file?(file)

    swiss_results = SwissHeatResult.from_file(file, heat)
    self.num_rows_processed = 0
    self.errors = nil

    current_row = nil
    begin
      TimeResult.transaction do
        swiss_results.each do |swiss_result|
          current_row = swiss_result
          process_single_swiss_result(swiss_result, heat)
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = "#{invalid} -> Original: #{current_row.bib_number} #{current_row.raw}"
      return false
    end
  end

  private

  def process_single_swiss_result(swiss_result, heat)
    competitor = FindCompetitorForCompetition.new(swiss_result.bib_number, competition).competitor

    heat_lane_result = HeatLaneResult.new(
      competition: competition,
      heat: heat,
      lane: swiss_result.lane,
      status: swiss_result.status,
      minutes: swiss_result.minutes,
      seconds: swiss_result.seconds,
      thousands: swiss_result.thousands,
      raw_data: swiss_result.raw,
      entered_at: DateTime.current,
      entered_by: @user
    )
    result = TimeResult.new(
      competitor: competitor,
      status: swiss_result.status,
      status_description: swiss_result.status_description,
      minutes: swiss_result.minutes,
      seconds: swiss_result.seconds,
      thousands: swiss_result.thousands,
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
