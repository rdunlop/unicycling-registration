# == Schema Information
#
# Table name: results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  result_type    :string(255)
#  result_subtype :integer
#  place          :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_results_on_competitor_id_and_result_type  (competitor_id,result_type) UNIQUE
#

class Result < ActiveRecord::Base
  include CachedSetModel

  def self.cache_set_field
    :competitor_id
  end

  belongs_to :competitor, inverse_of: :results

  validates :competitor, :place, :result_type, presence: true
  validates :competitor_id, uniqueness: { scope: [:result_type] }

  delegate :competition, to: :competitor

  def self.age_group
    where(result_type: "AgeGroup")
  end

  def self.overall
    where(result_type: "Overall")
  end

  # Filter Results to display only those which are marked as "Awarded" in the Database
  def self.awarded
    joins(competitor: [:competition]).merge(Competition.awarded)
  end

  def self.update_last_data_update_time(competition, datetime = DateTime.now)
    Rails.cache.write("/competition/#{competition.id}/last_data_update_time", datetime)
  end

  def self.update_last_calc_places_time(competition, datetime = DateTime.now)
    Rails.cache.write("/competition/#{competition.id}/last_calc_places_time", datetime)
  end

  def self.last_data_update_time(competition)
    Rails.cache.fetch("/competition/#{competition.id}/last_data_update_time")
  end

  def self.last_calc_places_time(competition)
    Rails.cache.fetch("/competition/#{competition.id}/last_calc_places_time")
  end

  def self.competition_calc_needed?(competition)
    ldut = last_data_update_time(competition)
    lcpt = last_calc_places_time(competition)
    lcpt.nil? || (ldut.present? && (ldut > lcpt))
  end

  def age_group_type?
    result_type == "AgeGroup"
  end

  def category_description
    if age_group_type?
      competitor.age_group_entry_description
    else
      "Overall"
    end
  end

  def to_s
    return "DQ" if status == "DQ"
    if place == 0 || place.nil?
      "Unknown"
    else
      place
    end
  end

  def self.create_new!(competitor, new_place, result_type, result_subtype = nil)
    if new_place == "DQ"
      new_place = 0
      status = "DQ"
    else
      status = nil
    end

    if result_type == "AgeGroup"
      existing_result = competitor.age_group_results.first
    else
      existing_result = competitor.overall_results.first
    end

    if existing_result
      if existing_result.place == new_place && existing_result.status == status && existing_result.result_subtype == result_subtype
        return
      else
        existing_result.place = new_place
        existing_result.status = status
        existing_result.result_subtype = result_subtype
        existing_result.save!
      end
    else
      result = Result.new(competitor: competitor, place: new_place, result_type: result_type, result_subtype: result_subtype, status: status)
      result.save!
    end
  end
end
