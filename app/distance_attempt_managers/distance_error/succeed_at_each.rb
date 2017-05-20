# Competitor must jump at the same distance as their previous fault
# Once a Competitor faults 3 attempts at the same distance, they are done, and their previous successful distance stands.
# After a fault, the next attempt must be at the same distance (no further), until they succeed, or are finished.
class DistanceError::SucceedAtEach
  attr_reader :distance_attempts, :distance

  def initialize(distance_attempts, distance)
    @distance_attempts = distance_attempts
    @distance = distance
  end

  def acceptable_distance?
    acceptable_distance_error(distance).nil?
  end

  def acceptable_distance_error
    if fault? && distance != max_attempted_distance
      "Riders must successfully complete each distance before moving on to the next distance. Please complete #{max_attempted_distance}cm"
    else
      # THis is very similar to GreaterThanorEqual#acceptable_distance_error...find a way to refactor?
      max_attempt = distance_attempts.first
      if max_attempt.present? && !max_attempt.fault?
        # no fault
        check_current_attempt_is_longer_than_previous_attempt(distance, max_attempt.distance)
      end
    end
  end

  def single_fault_message(distance)
    # doesn't have the "+" sign on the message
    "Fault. Next Distance #{distance}cm"
  end

  private

  def fault?
    if distance_attempts.count.positive?
      distance_attempts.first.fault?
    else
      false
    end
  end
end
