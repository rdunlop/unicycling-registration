class LodgingRoomOptionPresenter
  include ApplicationHelper

  attr_reader :lodging_room_option

  def initialize(lodging_room_option)
    @lodging_room_option = lodging_room_option
  end

  def days_available
    return "none" if lodging_room_option.lodging_days.none?

    first_date = nil
    current_date = nil
    output = []
    lodging_room_option.lodging_days.ordered.each do |day|
      if first_date.nil?
        # beginning of a range
        first_date = current_date = day.date_offered
      elsif (current_date + 1.day) == day.date_offered
        # consecutive days, increment current range
        current_date = day.date_offered
      else
        # non-consecutive days
        output << output_range(first_date, current_date)
        first_date = current_date = day.date_offered
      end
    end
    output << output_range(first_date, current_date)
    output.join(", ")
  end

  private

  def output_range(start_date, end_date)
    if start_date == end_date
      output_entry(start_date)
    else
      "#{output_entry(start_date)} - #{output_entry(end_date)}"
    end
  end

  def output_entry(date)
    I18n.l(date, format: :lodging_date_format)
  end
end
