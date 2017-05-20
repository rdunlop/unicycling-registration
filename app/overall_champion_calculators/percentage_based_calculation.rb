class PercentageBasedCalculation
  def self.calculate_points(competitor, entry, place)
    calc_perc_points(
      best_time: entry.best_time_in_thousands(competitor.gender),
      time: competitor.best_time_in_thousands,
      base_points: entry.base_points,
      bonus_percentage: entry.bonus_for_place(place)
    )
  end

  def self.calc_perc_points(best_time:, time:, base_points:, bonus_percentage:)
    return 0 if time.zero?
    points = (best_time * 1.0 / time) * base_points
    points + (points * bonus_percentage / 100.0)
  end
end
