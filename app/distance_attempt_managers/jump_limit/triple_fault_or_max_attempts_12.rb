# Limited to 12 attempts total OR triple-fault on a single distance
class JumpLimit::TripleFaultOrMaxAttempts12
  def no_more_jumps?(distance_attempts)
    JumpLimit::Attempts12.new.no_more_jumps?(distance_attempts) || JumpLimit::TripleFault.new.no_more_jumps?(distance_attempts)
  end
end
