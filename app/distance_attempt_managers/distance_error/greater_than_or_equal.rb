class DistanceError::GreaterThanOrEqual
  attr_reader :distance_attempts, :distance

  def initialize(distance_attempts, distance)
    @distance_attempts = distance_attempts
    @distance = distance
  end

  def acceptable_distance?
    acceptable_distance_error.nil?
  end

  def acceptable_distance_error
    max_attempt = distance_attempts.first
    if max_attempt.present?
      if max_attempt.fault?
        if distance < max_attempt.distance
          "New Distance (#{distance}cm) must be greater than or equal to #{max_attempt.distance}cm"
        end
      else
        # no fault
        check_current_attempt_is_longer_than_previous_attempt(max_attempt.distance)
      end
    end
  end

  private

  def check_current_attempt_is_longer_than_previous_attempt(max_distance)
    if distance <= max_distance
      "New Distance (#{distance}cm) must be greater than #{max_distance}cm"
    end
  end
end
