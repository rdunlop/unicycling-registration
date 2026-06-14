# == Schema Information
#
# Table name: trials_results
#
#  id            :bigint           not null, primary key
#  competitor_id :integer          not null
#  points        :integer          not null
#  minutes       :integer          not null
#  seconds       :integer          not null
#  details       :string
#  entered_at    :datetime         not null
#  entered_by_id :integer          not null
#  status        :string           not null
#  preliminary   :boolean          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_trials_results_on_competitor_id  (competitor_id) UNIQUE
#
class TrialsResult < ApplicationRecord
  include Competeable
  include Placeable
  include CachedSetModel

  def self.status_values
    ["active", "DQ"]
  end

  validates :competitor_id, uniqueness: true
  validates :status, inclusion: { in: TrialsResult.status_values }

  belongs_to :entered_by, class_name: 'User', inverse_of: false

  validates :points, presence: true
  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :seconds, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 60 }
  before_create :set_details_if_empty

  def self.cache_set_field
    :competitor_id
  end

  # "active" and "DQ" are considered active states
  def self.active
    where(preliminary: false)
  end

  def self.preliminary
    where(preliminary: true)
  end

  def active?
    !preliminary?
  end

  def disqualified?
    status == "DQ"
  end

  private

  def set_details_if_empty
    self.details = "#{points} pts (#{minutes}m #{seconds}s)" if details.blank?
  end
end
