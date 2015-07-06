class DistanceAttemptPreliminaryManager < DistanceAttemptManager

  MAX_ATTEMPTS = 12

  def no_more_jumps?
    distance_attempts.count >= MAX_ATTEMPTS
  end

end
