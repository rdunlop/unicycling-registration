# Base Class for all Distance Attempt Managers
# Helps determine the successful, unsuccessful distance for a competitor
class DistanceAttemptManager
  attr_accessor :competitor
  attr_reader :jump_limit_checker, :acceptable_distance_checker_class

  def initialize(competitor, jump_limit_checker, acceptable_distance_checker_class)
    @competitor = competitor
    @jump_limit_checker = jump_limit_checker
    @acceptable_distance_checker_class = acceptable_distance_checker_class
  end

  delegate :distance_attempts, to: :competitor

  def no_more_jumps?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/no_more_jumps") do
      jump_limit_checker.no_more_jumps?(distance_attempts)
    end
  end

  def acceptable_distance?(distance)
    acceptable_distance_error(distance).nil?
  end

  def acceptable_distance_error(distance)
    acceptable_distance_checker_object(distance).acceptable_distance_error
  end

  # Duplicated in DistanceError::SucceedAtEach
  def max_attempted_distance
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/max_attempted_distance") do
      return 0 unless distance_attempts.any?

      distance_attempts.first.distance
    end
  end

  def max_successful_distance
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/max_successful_distance") do
      max_successful_distance_attempt.try(:distance)
    end
  end

  def max_successful_distance_attempt
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/max_successful_distance_attempt") do
      distance_attempts.find_by(fault: false)
    end
  end

  def has_attempt?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/has_attempt?") do
      distance_attempts.any?
    end
  end

  def has_successful_attempt?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/has_successful_attempt?") do
      max_successful_distance_attempt.present?
    end
  end

  def distance_attempt_status_code
    if no_more_jumps?
      "cannot_attempt"
    else
      if single_fault?
        "single_fault"
      else
        "can_attempt"
      end
    end
  end

  def distance_attempt_status
    if distance_attempts.none?
      "Not Attempted"
    else
      if no_more_jumps?
        "Finished. Final Score #{max_successful_distance}cm"
      else
        if single_fault?
          acceptable_distance_checker_class.single_fault_message(max_attempted_distance)
        else
          "Success. Next Distance #{max_attempted_distance + 1}cm +"
        end
      end
    end
  end

  private

  def acceptable_distance_checker_object(distance)
    acceptable_distance_checker_class.new(distance_attempts, distance)
  end

  def distance_attempt_cache_key_base
    "/competitor/#{competitor.id}-#{competitor.updated_at}/#{DistanceAttempt.cache_key_for_set(competitor.id)}/"
  end

  def single_fault?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/single_fault?") do
      if distance_attempts.count.positive?
        distance_attempts.first.fault?
      else
        false
      end
    end
  end
end
