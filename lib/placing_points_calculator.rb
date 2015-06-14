class PlacingPointsCalculator
  attr_reader :place, :ties

  def initialize(place, ties)
    @place = place
    @ties = ties
  end

  def points
    total_points = 0
    current_place = place
    (ties + 1).times do
      total_points += current_place
      current_place += 1
    end
    total_points.to_f / (ties + 1)
  end
end


