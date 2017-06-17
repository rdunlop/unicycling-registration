class DefaultOverallCalculation
  def self.calculate_points(entry, place)
    if place > 0 && place <= 10 # rubocop:disable Style/NumericPredicate
      entry.send("points_#{place}")
    else
      0
    end
  end
end
