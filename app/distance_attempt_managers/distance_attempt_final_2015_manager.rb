# Competitor must jump at the same distance as their previous fault
# Once a Competitor faults 3 attempts at the same distance, they are done, and their previous successful distance stands.
# After a fault, the next attempt must be at the same distance (no further), until they succeed, or are finished.
class DistanceAttemptFinal_2015_Manager < DistanceAttemptManager
  def no_more_jumps?
    triple_fault?
  end

  def acceptable_distance_error(distance)
    if single_fault? && distance != max_attempted_distance
      "Riders must successfully complete each distance before moving on to the next distance. Please complete #{max_attempted_distance}cm"
    else
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

  # for distance_attempt logic, there are certain 'states' that a competitor can get into
  def triple_fault?
    Rails.cache.fetch("#{distance_attempt_cache_key_base}/triple_fault") do
      df = false
      if distance_attempts.count > 2
        if distance_attempts[0].fault? && distance_attempts[1].fault? && distance_attempts[2].fault?
          if distance_attempts[0].distance == distance_attempts[1].distance && distance_attempts[1].distance == distance_attempts[2].distance
            df = true
          end
        end
      end

      df
    end
  end
end
