class DistanceAttemptPreliminaryManager
  def self.build(competitor)
    DistanceAttemptManager.new(competitor, JumpLimit::Attempts12.new, DistanceError::GreaterThanOrEqual)
  end
end
