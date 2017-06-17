# Competitor must jump at the same distance as their previous fault
# After a fault, the next attempt must be at the same distance (no further), until they succeed, or are finished.
class DistanceError::SucceedAtEach
  attr_reader :distance_attempts, :distance

  def initialize(distance_attempts, distance)
    @distance_attempts = distance_attempts
    @distance = distance
  end

  def acceptable_distance_error
    if fault? && distance != max_attempted_distance
      "Riders must successfully complete each distance before moving on to the next distance. Please complete #{max_attempted_distance}cm"
    else
      # THis is very similar to GreaterThanorEqual#acceptable_distance_error...find a way to refactor?
      max_attempt = distance_attempts.first
      if max_attempt.present? && !max_attempt.fault?
        # no fault
        check_current_attempt_is_longer_than_previous_attempt(max_attempt.distance)
      end
    end
  end

  def self.single_fault_message(max_attempted_distance)
    # doesn't have the "+" sign on the message
    "Fault. Next Distance #{max_attempted_distance}cm"
  end

  private

  def max_attempted_distance
    return 0 unless distance_attempts.any?

    distance_attempts.first.distance
  end

  # DUPLICATED, I know..
  def check_current_attempt_is_longer_than_previous_attempt(max_distance)
    if distance <= max_distance
      "New Distance (#{distance}cm) must be greater than #{max_distance}cm"
    end
  end

  def fault?
    if distance_attempts.count.positive?
      distance_attempts.first.fault?
    else
      false
    end
  end
end
