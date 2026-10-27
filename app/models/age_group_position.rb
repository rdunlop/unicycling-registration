# == Schema Information
#
# Table name: age_group_positions
#
#  id                 :bigint           not null, primary key
#  competition_id     :bigint           not null
#  age_group_entry_id :bigint           not null
#  position           :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_age_group_positions_on_age_group_entry_id  (age_group_entry_id)
#  index_age_group_positions_unique                 (competition_id,age_group_entry_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (age_group_entry_id => age_group_entries.id)
#  fk_rails_...  (competition_id => competitions.id)
#

# The position of an AgeGroupEntry in a competition which orders its age groups itself
# (see CompetitionAgeGroups#move_age_group).
#
# Positions are stored per entry rather than per age group, so that the order survives
# combining (a combination takes the place of its first entry) and separating.
class AgeGroupPosition < ApplicationRecord
  belongs_to :competition
  belongs_to :age_group_entry

  validates :position, presence: true
end
