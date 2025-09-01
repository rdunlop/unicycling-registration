class MissingAgeGroupEntryWarning < ApplicationRecord
  validates :competition, presence: true
  validates :competitor, presence: true

  belongs_to :competition
  belongs_to :competitor

  scope :recent, -> { where("created_at > ?", 2.minutes.ago) }

  # Return the most recent entry for each competition
  def self.active
    where("created_at > ?", 1.week.ago)
  end

  def to_s
    "Unable to find suitable age group entry for competitors in #{competition}. For Example: #{competitor}"
  end

  # Create a new entry if needed
  # Return true on creation
  def self.create_if_needed(competition, competitor)
    return if MissingAgeGroupEntryWarning.recent.where(competition: competition).any?

    MissingAgeGroupEntryWarning.create(competition:, competitor:)
  end
end
