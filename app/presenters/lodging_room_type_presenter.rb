class LodgingRoomTypePresenter
  include ApplicationHelper

  attr_reader :lodging_room_type

  def initialize(lodging_room_type)
    @lodging_room_type = lodging_room_type
  end

  # determine the minimum number of days available, on any of the available days
  def min_days_remaining
    return "" if lodging_room_type.maximum_available.to_i.zero?

    # Select a unique set of lodging_day objects (unique by lodging_day.date_offered)
    # for each lodging_day, ask LodgingType for the num_selected_items
    lodging_days = lodging_room_type.lodging_room_options.map(&:lodging_days)
    unique_days = lodging_days.flatten.uniq { |ld| ld.date_offered }

    max_days_selected = unique_days.map { |lodging_day| lodging_room_type.num_selected_items(lodging_day) }.max

    lodging_room_type.maximum_available - max_days_selected
  end
end
