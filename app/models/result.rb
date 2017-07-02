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

class Result < ApplicationRecord
  include CachedSetModel
  include CachedModel

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

  def self.update_last_data_update_time(competition, datetime = DateTime.current)
    Rails.cache.write("/competition/#{competition.id}/last_data_update_time", datetime)
  end

  def self.update_last_calc_places_time(competition, datetime = DateTime.current)
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

  def use_for_awards?
    if age_group_type?
      competition.has_age_group_entry_results?
    else
      # this comparison is used many many places, can we find a good name for it?
      competition.has_experts? || !competition.has_age_group_entry_results?
    end
  end

  # Methods for use in describing this result for awards

  def competitor_name(registrant)
    res = "#{registrant.first_name} #{registrant.last_name}"
    if competitor.active_members.size == 2
      partner = (competitor.registrants - [registrant]).first

      res += " & " + partner.first_name + " " + partner.last_name
    end
    res
  end

  def competition_name
    competition.award_title_name
  end

  delegate :team_name, to: :competitor

  def category_name
    if competition.has_experts? && !age_group_type?
      if competitor.active_members.size > 1
        "Expert"
      else
        "Expert #{competitor.gender}"
      end
    else
      if competitor.competition.age_group_type.present?
        competitor.age_group_entry_description
      else
        competitor.competition.award_subtitle_name
      end
    end
  end

  def details
    competitor.result
  end

  # END OF awards-related methods

  def to_s
    return "DQ" if status == "DQ"
    if place.zero? || place.nil?
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
      existing_result = competitor.age_group_result
    else
      existing_result = competitor.overall_result
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
