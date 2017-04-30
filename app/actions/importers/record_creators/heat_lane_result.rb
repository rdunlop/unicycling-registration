class Importers::RecordCreators::HeatLaneResult
  def initialize(competition, user, heat)
    @competition = competition
    @user = user
    @heat = heat
  end

  def save(row_hash, row)
    build_and_save_imported_result(row_hash, row, @heat)
  end

  private

  def build_and_save_imported_result(input_row, row, heat)
    result = HeatLaneResult.new(
      entered_by: @user,
      entered_at: DateTime.current,
      heat: heat,
      lane: input_row[:lane],
      raw_data: row,
      competition: @competition,
      minutes: input_row[:minutes],
      seconds: input_row[:seconds],
      thousands: input_row[:thousands],
      status: input_row[:status]
    )
    result.save!
  end
end
