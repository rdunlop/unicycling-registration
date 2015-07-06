class DistanceAttemptFinalManager < DistanceAttemptManager

  def no_more_jumps?
    double_fault?
  end

end
