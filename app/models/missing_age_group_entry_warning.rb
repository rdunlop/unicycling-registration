# == Schema Information
#
# Table name: missing_age_group_entry_warnings
#
#  id             :bigint           not null, primary key
#  competition_id :bigint
#  competitor_id  :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  cmagew_competition  (competition_id)
#  cmagew_competitor   (competitor_id)
#
class MissingAgeGroupEntryWarning < ApplicationRecord
  validates :competition, presence: true
  validates :competitor, presence: true

  belongs_to :competition
  belongs_to :competitor

  scope :recent, -> { where("created_at > ?", 2.minutes.ago) }

  # Entries are considered active for 10 minutes
  def self.active
    where("created_at > ?", 10.minutes.ago)
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
