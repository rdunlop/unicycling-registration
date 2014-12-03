class PlaceCalculator
  def initialize
    reset
  end

  def reset
    @count = 1
    @previous_time = 0
    @tied_place = 0
  end

  def place_next(current_time, dq, ineligible = false)
    if dq || current_time == 0
      return "DQ"
    end

    # same time as previous time
    if @previous_time == current_time
      # set the tied place, if this is a new tie
      # return the tied place, which doesn't increase
      @tied_place = @count - 1 if @tied_place == 0
      place = @tied_place
    else
      # not the same time, so reset the ties counter
      @tied_place = 0

      # and set the place to the number of results (which will be the place, taking into account all ties)
      place = @count
    end

    unless ineligible
      # only increase the number of scores if the time is eligible
      @count += 1
      @previous_time = current_time
    end

    return place
  end

  private
end
