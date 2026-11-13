# == Schema Information
#
# Table name: age_group_combination_entries
#
#  id                       :bigint           not null, primary key
#  age_group_combination_id :bigint           not null
#  age_group_entry_id       :bigint           not null
#  competition_id           :bigint           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  idx_on_age_group_combination_id_c99ab34446                 (age_group_combination_id)
#  index_age_group_combination_entries_on_age_group_entry_id  (age_group_entry_id)
#  index_age_group_combination_entries_unique                 (competition_id,age_group_entry_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (age_group_combination_id => age_group_combinations.id)
#  fk_rails_...  (age_group_entry_id => age_group_entries.id)
#  fk_rails_...  (competition_id => competitions.id)
#

class AgeGroupCombinationEntry < ApplicationRecord
  belongs_to :age_group_combination, touch: true, inverse_of: :age_group_combination_entries
  belongs_to :age_group_entry
  # Denormalized from the combination, so that the database ensures an entry is combined once per competition
  belongs_to :competition

  before_validation :set_competition

  validates :age_group_entry_id, uniqueness: { scope: :competition_id, message: "is already combined in this competition" }

  private

  def set_competition
    self.competition_id = age_group_combination&.competition_id
  end
end
