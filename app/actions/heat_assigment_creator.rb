class HeatAssignmentCreator
  attr_accessor :competition, :num_lanes, :error

  def initialize(competition, num_lanes)
    @competition = competition
    @num_lanes = num_lanes
  end

  # Attempt to assign lane assignments for
  # all competitors, according to their age group, and
  # best time
  #
  # return true if successful
  # return false if unsuccessful (and sets the error variable)
  def perform
    current_heat = 1
    LaneAssignment.transaction do
      @competition.age_group_entries.each do |ag_entry|
        age_group_entries = @competition.competitors.includes(members: [registrant: :registrant_choices]).select {|competitor| competitor.age_group_entry == ag_entry }
        current_heat = create_heats_from(age_group_entries, current_heat, num_lanes)
      end
    end
  end

  private

  def create_heats_from(competitors, current_heat, max_lane_number)
    next_lane_number = 1
    heat_number = current_heat
    competitors.sort{|a, b| compare(a.best_time, b.best_time) }.each do |competitor|
      if next_lane_number > max_lane_number
        heat_number += 1
        next_lane_number = 1
      end
      LaneAssignment.create!(competitor: competitor, lane: next_lane_number, heat: heat_number, competition: competitor.competition)
      next_lane_number += 1
    end
    return heat_number if next_lane_number == 1
    heat_number + 1
  end

  # a comparison between a and b
  # return -1 when a < b (i.e. leave the order alone)
  # return 0 when a and b are equivalent
  # return +1 if a > b. (i.e. invert the order)
  #
  # Sorts `nil` first, then larger numbers, followed by smaller numbers
  def compare(a, b)
    if a.nil? || b.nil?
      if a.nil? && b.nil?
        return 0
      end
      return -1 if a.nil?
      return 1
    end
    b.try(:value) <=> a.try(:value)
  end
end
