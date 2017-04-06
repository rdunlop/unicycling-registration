# Competitor must jump at the same distance as their previous fault
# Once a Competitor faults 3 attempts at the same distance, they are done, and their previous successful distance stands.
# After a fault, the next attempt must be at the same distance (no further), until they succeed, or are finished.
class JumpLimit::DoubleFault
  def no_more_jumps?(distance_attempts)
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
