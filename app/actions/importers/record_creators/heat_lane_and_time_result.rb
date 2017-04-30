class Importers::RecordCreators::HeatLaneAndTimeResult
  def initialize(competition, user, heat, heats: true)
    @competition = competition
    @user = user
    @heat = heat
    @heats = heats
  end

  def save(row_hash, _row)
    build_and_save_imported_result(row_hash, @heat, @heats)
  end

  private

  def build_and_save_imported_result(row_hash, heat, heats)
    heat_lane_result = nil
    if heats
      heat_lane_result = create_heat_lane_result(row_hash, heat)
    end
    create_time_result(row_hash, heat_lane_result)
  end

  def create_heat_lane_result(row_hash, heat)
    heat_lane_result = HeatLaneResult.new(
      competition: @competition,
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
    competitor = FindCompetitorForCompetition.new(row_hash[:bib_number], @competition).competitor
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
