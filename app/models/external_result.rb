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
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id)
#

class ExternalResult < ActiveRecord::Base
  include Competeable
  include Placeable
  include CachedSetModel

  validates :points, presence: true

  def self.cache_set_field
    :competitor_id
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

  def disqualified
    false
  end

  def result
    points
  end
end
