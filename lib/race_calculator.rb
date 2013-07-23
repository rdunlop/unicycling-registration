class RaceCalculator

  def initialize(competition)
    @competition = competition
  end

  # update the places for all age groups
  def update_all_places
    age_group_type = @competition.age_group_type
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
    count = 1
    previous_time = 0
    tied_place = 0

    @competition.time_results.order("minutes, seconds, thousands").each do |tr|

      # only perform updates on the specified age group entry set
      next if tr.age_group_entry_description != age_group_entry_description

      current_time = tr.full_time_in_thousands

      if tr.disqualified or current_time == 0
        tr.place = 0
        next
      end


      if previous_time == current_time
        tied_place = count - 1 if tied_place == 0
        place = tied_place
      else
        place = count
        tied_place = 0
      end
      count += 1
      previous_time = current_time
      tr.place = place
    end
  end

  def update_overall_places(gender)
    count = 1
    previous_time = 0
    tied_place = 0

    @competition.time_results.order("minutes, seconds, thousands").each do |tr|
      next if tr.competitor.gender != gender

      current_time = tr.full_time_in_thousands

      if tr.disqualified or current_time == 0
        tr.place = 0
        next
      end

      if previous_time == current_time
        tied_place = count - 1 if tied_place == 0
        place = tied_place
      else
        place = count
        tied_place = 0
      end
      count += 1
      previous_time = current_time
      tr.overall_place = place
    end
  end
end
