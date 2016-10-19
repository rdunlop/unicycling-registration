class AverageSpeedCalculation
  M_TO_KM = (1.0 / 1_000).freeze

  #                               MS     SEC  MIN
  THOUSANDS_TO_HOURS = (1.0 / (1_000 * 60 * 60)).freeze

  def self.calculate_points(competitor, entry)
    distance = entry.distance
    time_in_thousands = competitor.best_time_in_thousands

    (distance * M_TO_KM) / (time_in_thousands * THOUSANDS_TO_HOURS)
  end
end
