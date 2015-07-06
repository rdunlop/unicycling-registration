class DistanceAttemptFinal_2015_Manager < DistanceAttemptManager
  def no_more_jumps?
    triple_fault?
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
