class RaceCalculator

  def initialize(event_category)
    @event_category = event_category
  end

  # update the places for an event, fastest first.
  # DQ are marked as place = 0
  # results with time==0 are marked as place = 0
  def update_places
    count = 1
    previous_time = 0
    tied_place = 0

    @event_category.time_results.order("minutes, seconds, thousands").each do |tr|
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
