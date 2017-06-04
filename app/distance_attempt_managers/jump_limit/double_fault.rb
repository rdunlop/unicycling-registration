# Pre-2015 High/Long calculations (most recently used at UNICON 2014 in Montreal)
class JumpLimit::DoubleFault
  def no_more_jumps?(distance_attempts)
    if distance_attempts.count > 1
      if distance_attempts[0].fault? && distance_attempts[1].fault? && distance_attempts[0].distance == distance_attempts[1].distance
        return true
      end
    end

    false
  end
end
