# == Schema Information
#
# Table name: published_age_group_entries
#
#  id                       :integer          not null, primary key
#  competition_id           :integer
#  age_group_entry_id       :integer
#  published_at             :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  age_group_combination_id :bigint
#
# Indexes
#
#  index_published_age_group_entries_on_age_group_combination_id  (age_group_combination_id)
#  index_published_age_group_entries_on_competition_id            (competition_id)
#
# Foreign Keys
#
#  fk_rails_...  (age_group_combination_id => age_group_combinations.id)
#

class PublishedAgeGroupEntry < ApplicationRecord
  belongs_to :competition, touch: true
  belongs_to :age_group_entry, optional: true
  belongs_to :age_group_combination, optional: true

  validate :exactly_one_age_group

  before_create :set_published_at_date

  delegate :to_s, to: :age_group

  # The published AgeGroupEntry or AgeGroupCombination
  def age_group
    age_group_combination || age_group_entry
  end

  def age_group=(age_group)
    if age_group.is_a?(AgeGroupCombination)
      self.age_group_combination = age_group
      self.age_group_entry = nil
    else
      self.age_group_entry = age_group
      self.age_group_combination = nil
    end
  end

  def published_formatted
    published_at.to_formatted_s(:rfc822)
  end

  private

  def exactly_one_age_group
    return if age_group_entry.present? ^ age_group_combination.present?

    errors.add(:base, "Must be published for exactly one age group")
  end

  def set_published_at_date
    self.published_at = Time.current
  end
end
