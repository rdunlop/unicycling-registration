class RaceCalculator

  def initialize(competition)
    @competition = competition
  end

  # update the places for all age groups
  def update_all_places
    need_overall_update_male = false
    need_overall_update_female = false
    @competition.competitors.each do |competitor|
      if competitor.place == "Unknown"
        update_places(competitor.age_group_entry_description) unless competitor.time_results.count == 0
      end
      if competitor.gender == "Male" and competitor.overall_place == "Unknown"
        need_overall_update_male = true
      end
      if competitor.gender == "Female" and competitor.overall_place == "Unknown"
        need_overall_update_female = true
      end
    end
    #age_group_type = @competition.determine_age_group_type
    #unless age_group_type.nil?
      #age_group_type.age_group_entries.each do |age|
        #update_places(age.to_s)
      #end
    #end
    update_overall_places("Male") if need_overall_update_male
    update_overall_places("Female") if need_overall_update_female
  end


  private
  # update the places for an event, fastest first.
  # DQ are marked as place = 0
  # results with time==0 are marked as place = 0
  def update_places(age_group_entry_description)
    return 0 if age_group_entry_description.nil?

    place_calc = PlaceCalculator.new

    @competition.time_results.includes(:competitor).order("minutes, seconds, thousands").each do |tr|

      # only perform updates on the specified age group entry set
      next if tr.competitor.age_group_entry_description != age_group_entry_description

      tr.competitor.place = place_calc.place_next(tr.full_time_in_thousands, tr.disqualified, tr.competitor.ineligible)
    end
  end

  def update_overall_places(gender)

    place_calc = PlaceCalculator.new

    @competition.time_results.includes(:competitor).order("minutes, seconds, thousands").each do |tr|
      next if tr.competitor.gender != gender

      tr.competitor.overall_place = place_calc.place_next(tr.full_time_in_thousands, tr.disqualified, tr.competitor.ineligible)
    end
  end
end
