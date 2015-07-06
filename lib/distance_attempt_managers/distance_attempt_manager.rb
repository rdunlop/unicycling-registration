# Base Class for all Distance Attempt Managers
# Helps determine the successful, unsucessful distance for a competitor
class DistanceAttemptManager
  attr_accessor :competitor

  def initialize(competitor)
    @competitor = competitor
  end

  delegate :distance_attempts, to: :competitor

  def no_more_jumps?
    raise NotImplementedError
  end

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
    if double_fault?
      "double_fault"
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
        "Finished. Final Score #{max_successful_distance}"
      else
        if single_fault?
          "Fault. Next Distance #{max_attempted_distance}+"
        else
          "Success. Next Distance #{max_attempted_distance + 1}+"
        end
      end
    end
  end

  private

  def distance_attempt_cache_key_base
    "/competitor/#{competitor.id}-#{competitor.updated_at}/#{DistanceAttempt.cache_key_for_set(competitor.id)}/"
  end

  # for distance_attempt logic, there are certain 'states' that a competitor can get into
  def double_fault?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/double_fault") do
      df = false
      if distance_attempts.count > 1
        if distance_attempts[0].fault? && distance_attempts[1].fault? && distance_attempts[0].distance == distance_attempts[1].distance
          df = true
        end
      end

      df
    end
  end

  def single_fault?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/single_fault?") do
      if distance_attempts.count > 0
        distance_attempts.first.fault?
      else
        false
      end
    end
  end

end
