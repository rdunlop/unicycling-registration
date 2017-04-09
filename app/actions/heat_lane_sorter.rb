class HeatLaneSorter
  attr_accessor :lane_assignments, :previous_heat_lanes, :move_lane, :new_order_lane_assignment_ids

  def initialize(new_order_lane_assignment_ids, move_lane: false)
    @new_order_lane_assignment_ids = new_order_lane_assignment_ids
    @lane_assignments = fetch_lane_assignments
    @previous_heat_lanes = lane_assignments.map{|la| [la.heat, la.lane] }
    @move_lane = move_lane
    @found_moved_lane = false
    @new_lanes = []
    @moved_heat = 0
    @moved_lane = 0
  end

  def needs_to_change?(lane_assignment, heat_lane)
    heat_lane[0] != lane_assignment.heat || heat_lane[1] != lane_assignment.lane
  end

  # manually re-sort the lane assignments
  #
  # Initial Values:
  # IDS
  # 1 2 3 4           5 6 7 8
  #
  # Heat 1            Heat 2
  # Lane
  # 1 2 3 4           1 2 3 4
  #
  # Given the following inputs:
  #
  # 1 2 3 4 6 7 8 5
  #
  # it should re-sort to be
  # Heat 1            Heat 2
  # 1 2 3 4           6 7 8 5
  #
  #
  # Given the following inputs
  #
  # 1 2 3 4
  #
  # .................????
  def sort
    # holds the list of all heats/lanes

    LaneAssignment.transaction do
      # find which are needing to move,
      # assign them to positions which are un-occupied
      new_order_lane_assignment_ids.each_with_index do |lane_assignment_id, index|
        la = LaneAssignment.find(lane_assignment_id)
        next unless needs_to_change?(la, previous_heat_lanes[index])

        la.update_attributes(lane: la.lane + 100)
      end

      new_order_lane_assignment_ids.each_with_index do |lane_assignment_id, index|
        la = LaneAssignment.find(lane_assignment_id)
        next unless needs_to_change?(la, previous_heat_lanes[index])

        move_to_new_position(la, index)
      end
    end

    fetch_lane_assignments
  end

  private

  def fetch_lane_assignments
    LaneAssignment.where(id: new_order_lane_assignment_ids).order(:heat, :lane)
  end

  def move_to_new_position(lane_assignment, index)
    if move_lane
      unless @found_moved_lane
        @moved_heat = previous_heat_lanes[index][0]
        @moved_lane = previous_heat_lanes[index][1]
        @found_moved_lane = true
      end
      if @found_moved_lane && lane_assignment.heat == @moved_heat && lane_assignment.lane == @moved_lane
        # this is the lane that we moved
        lane_assignment.update_attributes(heat: previous_heat_lanes[index][0], lane: previous_heat_lanes[index][1] + 1)
      end
    else
      lane_assignment.update_attributes(heat: previous_heat_lanes[index][0], lane: previous_heat_lanes[index][1])
    end
  end
end
