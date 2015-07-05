# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string(255)
#  points        :decimal(6, 3)    not null
#  created_at    :datetime
#  updated_at    :datetime
#  entered_by_id :integer          not null
#  entered_at    :datetime         not null
#  status        :string           not null
#  preliminary   :boolean          not null
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id)
#

class ExternalResult < ActiveRecord::Base
  include Competeable
  include Placeable
  include CachedSetModel

  def self.status_values
    ["active", "DQ"]
  end

  validates :status, inclusion: { in: ExternalResult.status_values }

  belongs_to :entered_by, class_name: 'User', foreign_key: :entered_by_id

  validates :points, presence: true

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

  # from CSV to import_result
  def self.build_and_save_imported_result(raw, raw_data, user, competition)
    ImportResult.create(
      bib_number: raw[0],
      points: raw[1],
      details: raw[2],
      raw_data: raw_data,
      user: user,
      competition: competition)
  end

  def disqualified?
    false
  end

  def result
    points
  end
end
