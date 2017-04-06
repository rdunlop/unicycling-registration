class JumpLimit::Attempts12
  MAX_ATTEMPTS = 12

  def no_more_jumps?(distance_attempts)
    distance_attempts.count >= MAX_ATTEMPTS
  end
end
