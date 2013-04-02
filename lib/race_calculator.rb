class RaceCalculator

  def initialize(event_category, age, gender)
    @event_category = event_category
    age_group_type = event_category.age_group_type
    unless age_group_type.nil?
      @age_group_entry = age_group_type.age_group_entry_for(age, gender)
    end
  end

  # update the places for an event, fastest first.
  # DQ are marked as place = 0
  # results with time==0 are marked as place = 0
  def update_places
    return 0 if @age_group_entry.nil?
    count = 1
    previous_time = 0
    tied_place = 0

    @event_category.time_results.includes(:registrant, :event_category).order("minutes, seconds, thousands").each do |tr|

      # only perform updates on the specified age group entry set
      next if tr.age_group_entry != @age_group_entry

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
end
