class HeatAssignmentCreator
  attr_accessor :competition, :heat_lane_calculator, :error

  def initialize(competition, heat_lane_calculator)
    @competition = competition
    @heat_lane_calculator = heat_lane_calculator
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
        competitors = @competition.competitors.includes(members: [registrant: :registrant_choices]).select {|competitor| competitor.age_group_entry == ag_entry }
        sorted_competitors = competitors.sort{|a, b| compare(a.best_time, b.best_time) }
        heat_lane_list = create_heats_from(sorted_competitors.count, current_heat)
        current_heat = heat_lane_list.any? ? (heat_lane_list.last[:heat] + 1) : current_heat
        assign_heat_lanes(heat_lane_list, sorted_competitors)
      end
    end
  end

  private

  def assign_heat_lanes(heat_lane_list, competitors)
    competitors.each_with_index do |competitor, i|
      LaneAssignment.create!(
        competitor: competitor,
        heat: heat_lane_list[i][:heat],
        lane: heat_lane_list[i][:lane],
        competition: competitor.competition)
    end
  end

  def create_heats_from(num_competitors, current_heat)
    heat_lane_calculator.heat_lane_list(num_competitors, current_heat)
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
