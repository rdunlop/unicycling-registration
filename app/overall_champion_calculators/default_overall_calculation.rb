class DefaultOverallCalculation
  def self.calculate_points(entry, place)
    if entry.combined_competition.range_of_places.include?(place)
      entry.send("points_#{place}").to_i
    else
      0
    end
  end
end
