class DistanceCalculator
  # FOR TWO-ATTEMPT-DISTANCE (like High/Long jump)

  def initialize(competition)
    @competition = competition
  end

  # update the places for all age groups
  def update_all_places
    age_group_type = @competition.determine_age_group_type
    unless age_group_type.nil?
      age_group_type.age_group_entries.each do |age|
        update_places(age.to_s)
      end
    end
    update_overall_places("Male")
    update_overall_places("Female")
  end


  private
  # update the places for an event, fastest first.
  # DQ are marked as place = 0
  # results with time==0 are marked as place = 0
  def update_places(age_group_entry_description)
    return 0 if age_group_entry_description.nil?

    place_calc = PlaceCalculator.new

    distance_attempts = @competition.best_distance_attempts
    distance_attempts.each do |da|
      # only perform updates on the specified age group entry set
      next if da.competitor.age_group_entry_description != age_group_entry_description

      da.competitor.place = place_calc.place_next(da.distance, da.fault, da.competitor.ineligible)
    end
  end

  def update_overall_places(gender)

    place_calc = PlaceCalculator.new

    distance_attempts = @competition.best_distance_attempts
    distance_attempts.each do |da|
      next if da.competitor.gender != gender

      da.competitor.overall_place = place_calc.place_next(da.distance, da.fault, da.competitor.ineligible)
    end
  end
end
