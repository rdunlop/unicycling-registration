# Competitor must jump at the same distance as their previous fault
# Once a Competitor faults 3 attempts at the same distance, they are done, and their previous successful distance stands.
class JumpLimit::TripleFault
  def no_more_jumps?(distance_attempts)
    if distance_attempts.count > 2
      if distance_attempts[0].fault? && distance_attempts[1].fault? && distance_attempts[2].fault?
        if distance_attempts[0].distance == distance_attempts[1].distance && distance_attempts[1].distance == distance_attempts[2].distance
          return true
        end
      end
    end

    false
  end
end
