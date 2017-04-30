class Importers::RecordCreators::ImportResult
  def initialize(competition, user, start_times)
    @competition = competition
    @user = user
    @is_start_time = start_times || false
  end

  def save(row_hash, row)
    build_and_save_imported_result(row_hash, row, @user, @competition, @is_start_time)
  end

  private

  # Create an ImportResult object.
  # Throws an exception if not valid
  def build_and_save_imported_result(hash, raw, user, competition, is_start_time)
    ImportResult.create!(
      bib_number: hash[:bib_number],
      minutes: hash[:minutes],
      seconds: hash[:seconds],
      thousands: hash[:thousands],
      number_of_laps: hash[:number_of_laps],
      status: hash[:status],
      raw_data: convert_array_to_string(raw),
      user: @user,
      competition: @competition,
      is_start_time: is_start_time)
  end

  def convert_array_to_string(arr)
    str = "["
    arr.each do |el|
      str += "#{el},"
    end
    str += "]"
    str
  end
end
