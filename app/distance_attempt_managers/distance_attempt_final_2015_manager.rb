# Competitor must jump at the same distance as their previous fault
# Once a Competitor faults 3 attempts at the same distance, they are done, and their previous successful distance stands.
# After a fault, the next attempt must be at the same distance (no further), until they succeed, or are finished.
class DistanceAttemptFinal_2015_Manager
  def build(competitor)
    DistanceAttemptManager.new(competitor, JumpLimit::TripleFault.new, DistanceError::SucceedAtEach)
  end
end
