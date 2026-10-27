# == Schema Information
#
# Table name: age_group_combinations
#
#  id             :bigint           not null, primary key
#  competition_id :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_age_group_combinations_on_competition_id  (competition_id)
#
# Foreign Keys
#
#  fk_rails_...  (competition_id => competitions.id)
#

# A view over several contiguous AgeGroupEntries of a competition's age group type,
# in which competitors are ranked together.
#
# The underlying AgeGroupEntries are never modified, so a combination
# can be removed to restore the original age groups.
# Conversely, the AgeGroupType of combined entries cannot be modified (see AgeGroupType#combined?).
class AgeGroupCombination < ApplicationRecord
  include AgeGroupMatching

  belongs_to :competition, touch: true, inverse_of: :age_group_combinations
  has_many :age_group_combination_entries, dependent: :destroy, inverse_of: :age_group_combination
  has_many :age_group_entries, through: :age_group_combination_entries
  has_many :published_age_group_entries, dependent: :destroy

  after_save :expire_cache
  after_touch :expire_cache
  after_destroy :expire_cache
  after_rollback :expire_cache

  def sorted_age_group_entries
    age_group_entries.sort_by(&:start_age)
  end

  def gender
    age_group_entries.first&.gender
  end

  def wheel_size_id
    age_group_entries.first&.wheel_size_id
  end

  def wheel_size_name
    age_group_entries.first&.wheel_size_name
  end

  def start_age
    age_group_entries.map(&:start_age).min
  end

  def end_age
    age_group_entries.map(&:end_age).max
  end

  def short_description
    sorted_age_group_entries.map(&:short_description).join(" and ")
  end

  def to_age_group_param
    "combination-#{id}"
  end

  def to_s
    [short_description, wheel_size_name].compact.join(", ")
  end

  private

  def expire_cache
    AgeGroupCombinationCache.expire(competition_id)
  end
end
