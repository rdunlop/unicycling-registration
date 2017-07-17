# The PlaceCalculator acts as a sort of accumulator-state system for keeping track of points
# It MUST be called in the correct order, with the person who placed first being called first
# Each time it is called with a new score, it compares it to the previous score
# to determine whether this is a new place, or a tie for the place.
class PlaceCalculator
  def initialize
    reset
  end

  def reset
    @count = 1
    @previous_points = 0
    @previous_tie_points = 0
    @tied_place = 0
  end

  # Always call this function with the current_points
  # If the competition has scores and tie-break points,
  # the calling function must ensure that they are ordered in descending order (best place first, etc)
  # Options:
  #  dq: Is this competitor disqualified?
  #  tie_break_points: if this score is a tie, is there a score which should be compared for tie-breaking purposes?
  def place_next(current_points, options = {})
    dq = options[:dq]
    tie_break_points = options[:tie_break_points]

    if dq || current_points.zero?
      return "DQ"
    end

    # same time as previous time
    if @previous_points == current_points && @previous_tie_points == tie_break_points
      # set the tied place, if this is a new tie
      # return the tied place, which doesn't increase
      @tied_place = @count - 1 if @tied_place.zero?
      place = @tied_place
    else
      # not the same score as the previous, so reset the ties counter
      @tied_place = 0

      # and set the place to the number of results (which will be the place, taking into account all ties)
      place = @count
    end

    @count += 1
    @previous_points = current_points
    @previous_tie_points = tie_break_points

    place
  end
end
