# == Schema Information
#
# Table name: distance_attempts
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  distance      :decimal(4, )
#  fault         :boolean          default(FALSE), not null
#  judge_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_distance_attempts_competitor_id  (competitor_id)
#  index_distance_attempts_judge_id       (judge_id)
#

class DistanceAttempt < ActiveRecord::Base
  include Competeable
  include Placeable
  include CachedSetModel
  delegate :competition, to: :judge # override to use judge path instead of competitor path
  # because on object creation, competitor doesn't exist.
  include CompetitorAutoCreation

  belongs_to :judge

  validates :judge_id,      presence: true
  validates :distance,      presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 1000}

  validate :must_not_have_new_attempt_less_than_existing_attempt
  validate :cannot_have_new_attempts_after_double_fault

  def self.cache_set_field
    :competitor_id
  end

  def must_not_have_new_attempt_less_than_existing_attempt
    if new_record?
      unless competitor.nil? || distance.nil?
        if competitor.max_attempted_distance > distance
          errors[:distance] << "New Distance (#{distance}) must be equal or greater than existing max distance attempt (#{competitor.max_attempted_distance})"
        end
      end
    end
  end

  def cannot_have_new_attempts_after_double_fault
    if new_record?
      unless competitor.nil? || distance.nil?
        if competitor(true).double_fault?
          errors[:base] << "Unable to make new attempts after having double fault (fault_distance: #{competitor.max_attempted_distance})"
        end
      end
    end
  end

  def result
    distance
  end

  def disqualified?
    fault
  end
end
