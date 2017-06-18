# Competitor must jump at the same distance as their previous fault
# Once a Competitor faults 3 attempts at the same distance, they are done, and their previous successful distance stands.
# After a fault, the next attempt must be at the same distance (no further), until they succeed, or are finished.
# Maximum of 12 attempts total
class DistanceAttemptPreliminary2017Manager
  def self.build(competitor)
    DistanceAttemptManager.new(competitor, JumpLimit::TripleFaultOrMaxAttempts12.new, DistanceError::SucceedAtEach)
  end
end
