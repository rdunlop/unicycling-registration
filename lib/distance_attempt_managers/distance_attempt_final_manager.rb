# Pre-2015 High/Long calculations (most recently used at UNICON 2014 in Montreal)
class DistanceAttemptFinalManager < DistanceAttemptManager

  def no_more_jumps?
    double_fault?
  end

end
