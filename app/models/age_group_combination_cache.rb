# Per-request (and per-job) cache of the AgeGroupCombinations (and AgeGroupPositions) of each competition,
# indexed by the id of their AgeGroupEntries.
#
# Competitors are often loaded through other records (lane assignments, results...),
# each with its own Competition instance: this avoids loading the combinations once per competitor.
#
# It is expired when combinations or positions change in this process (the entries of combinations
# cannot change, see AgeGroupType#combined?), and reset by the Rails executor around each request
# and job. A long-lived process outside the executor
# (e.g. a rails console) does not see changes made by other processes until
# `AgeGroupCombinationCache.reset` (or Competition#reload) is called.
class AgeGroupCombinationCache < ActiveSupport::CurrentAttributes
  attribute :by_competition_id

  def self.fetch(competition_id)
    self.by_competition_id ||= {}
    by_competition_id[key(competition_id)] ||= yield
  end

  def self.expire(competition_id)
    by_competition_id&.delete(key(competition_id))
  end

  # Competition ids are only unique within a tenant
  def self.key(competition_id)
    [Apartment::Tenant.current, competition_id]
  end
end
