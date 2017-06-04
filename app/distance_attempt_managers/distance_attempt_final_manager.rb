# Pre-2015 High/Long calculations (most recently used at UNICON 2014 in Montreal)
class DistanceAttemptFinalManager
  def self.build(competitor)
    DistanceAttemptManager.new(competitor, JumpLimit::DoubleFault.new)
  end
end
