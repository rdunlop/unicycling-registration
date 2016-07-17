class HeatLaneCalculator
  DEFAULT_LANE_ASSIGNMENT_ORDER = [1, 2, 3, 4, 5, 6, 7, 8].freeze
  attr_accessor :num_lanes, :lane_assignment_order

  # lane_assignment_order is the order in which the lanes are best
  # ie: the best-seeded competitor should be given the first lane, etc etc
  def initialize(num_lanes, lane_assignment_order: DEFAULT_LANE_ASSIGNMENT_ORDER)
    @num_lanes = num_lanes
    @lane_assignment_order = lane_assignment_order.take(num_lanes)
    raise "Unable to process with lane order fewer than number of lanes" if lane_assignment_order.count < num_lanes
  end

  def heat_lane_list(num_competitors, first_heat_number)
    next_lane_number_index = 0
    current_heat_number = first_heat_number

    heat_lane_assignments = []
    competitors_per_heat(num_competitors).each do |num_competitors_in_heat| # array [5,5,4]
      # fill this heat
      next_lane_number_index = 0
      num_competitors_in_heat.times do # 5
        heat_lane_assignments << { heat: current_heat_number, lane: lane_number(next_lane_number_index, num_competitors_in_heat) }
        next_lane_number_index += 1
      end
      # done with heat
      current_heat_number += 1
    end

    heat_lane_assignments
  end

  private

  # Given index 0, we provide the worst possible lane, which is the last
  # provided lane
  def lane_number(index, num_competitors_in_heat)
    # if there are 8 lanes provided in the `lane_assignment_order`
    # but only 4 `num_lanes`
    # and we only have 3 competitors in this heat, then the indices
    # should be 2,1,0
    lane_assignment_order[num_competitors_in_heat - 1 - index]
  end

  # return an array of integers, each is the number
  # of competitors for that heat.
  # it should be as balanced as possible
  def competitors_per_heat(num_competitors)
    return [] if num_competitors == 0
    num_heats = (num_competitors.to_f / num_lanes).ceil

    # uses the Rails `in_groups` function to equally split into num_heats
    # groups, distributing the extras
    (1..num_competitors).to_a.in_groups(num_heats, false).map(&:count)
  end
end
