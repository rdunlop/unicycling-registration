# == Schema Information
#
# Table name: competitors
#
#  id                 :integer          not null, primary key
#  competition_id     :integer
#  position           :integer
#  custom_external_id :integer
#  custom_name        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Competitor < ActiveRecord::Base
  include Eligibility

    has_many :members, :inverse_of => :competitor
    has_many :registrants, -> { order "bib_number" }, :through => :members
    belongs_to :competition
    acts_as_list :scope => :competition

    has_many :scores, :dependent => :destroy
    has_many :boundary_scores, :dependent => :destroy
    has_many :street_scores, :dependent => :destroy
    has_many :standard_execution_scores, :dependent => :destroy
    has_many :standard_difficulty_scores, :dependent => :destroy
    has_many :distance_attempts, -> { order "distance DESC, id DESC" }, :dependent => :destroy
    has_many :time_results, :dependent => :destroy
    has_many :external_results, :dependent => :destroy

    accepts_nested_attributes_for :registrants

    validates :competition_id, :presence => true
    validates_associated :members
    validate :must_have_3_members_for_custom_name

    # not all competitor types require a position
    #validates :position, :presence => true,
                         #:numericality => {:only_integer => true, :greater_than => 0}

    after_touch(:touch_places)
    after_save(:touch_places)

    def touch_places
      # update the last time for the overall gender
      if overall_cache_value.nil?
        Rails.cache.write(overall_key, 0)
      end
      Rails.cache.increment(overall_key, 1)
      # invalidate the cache for age-group-entry entries
      if age_group_cache_value.nil?
        Rails.cache.write(age_group_key, 0)
      end
      Rails.cache.increment(age_group_key, 1)
    end

    def must_have_3_members_for_custom_name
      if (registrants.size < 3 and members.size < 3) and !custom_name.blank?
        errors[:base] << "Must have at least 3 members to specify a custom name"
      end
    end

    def to_s
      name
    end

    def bib_number
      members.first.registrant.bib_number
    end

    def place=(place)
      Rails.cache.write(place_key, place)
    end

    def place
      my_place = Rails.cache.fetch(place_key)

      if my_place.nil? and (has_result?)
        sc = competition.score_calculator
        sc.try(:update_all_places)
        my_place = Rails.cache.fetch(place_key)
      end
      my_place || "Unknown"
    end

    def overall_place=(place)
      Rails.cache.write(overall_place_key, place)
    end

    def overall_place
      my_overall_place = Rails.cache.fetch(overall_place_key)

      if my_overall_place.nil? and (has_result?)
        sc = competition.score_calculator
        sc.try(:update_all_places)
        my_overall_place = Rails.cache.fetch(overall_place_key)
      end
      my_overall_place || "Unknown"
    end

    def age_group_entry_description # XXX combine with the other age_group function
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/competition/#{competition.id}-#{competition.updated_at}/age_group_entry_description") do
        registrant = members.first.try(:registrant)
        competition.get_age_group_entry_description(registrant.age, registrant.gender, registrant.default_wheel_size.id) unless registrant.nil?
      end
    end

    #private
    def age_group_key
      "/competition/#{competition.id}-#{competition.updated_at}/age_group/#{age_group_entry_description}/version"
    end
    def overall_key
      "/competition/#{competition.id}-#{competition.updated_at}/gender/#{gender}/overall_version"
    end

    def age_group_cache_value
      Rails.cache.fetch(age_group_key)
    end

    def overall_cache_value
      Rails.cache.fetch(overall_key)
    end

    def place_key
      competition.reload
      "/competition/#{competition.id}-#{competition.updated_at}/competitor/#{id}-#{updated_at}/age_group_count/#{age_group_cache_value}/place"
    end

    def overall_place_key
      "/competition/#{competition.id}-#{competition.updated_at}competitor/#{id}-#{updated_at}/overall_count/#{overall_cache_value}/overall_place"
    end

    public
    def has_result?
      competition.scoring_helper.competitor_has_result?(self)
    end

    def result
      competition.scoring_helper.competitor_result(self)
    end

    def event
      competition.event
    end

    def member_has_bib_number?(bib_number)
      return members.includes(:registrant).where({:registrants => {:bib_number => bib_number}}).count > 0
    end

    def team_name
      unless custom_name.nil? or custom_name.empty?
        custom_name
      end
    end

    def name
      if custom_name.present?
        comp_name = custom_name
      else
        comp_name = registrants_names
      end
      display_eligibility(comp_name, ineligible)
    end

    def registrants_names
      if registrants.empty?
        "(No registrants)"
      else
        registrants.map(&:name).join(" - ")
      end
    end

    def registrants_ids
      if registrants.empty?
        "(No registrants)"
      else
        registrants.map(&:external_id).join(",")
      end
    end

    def detailed_name
      if custom_name.present?
        "#{custom_name} (#{registrants_names})"
      else
        registrants_names
      end
    end

    def external_id
      if custom_external_id.present? && custom_external_id != 0
        custom_external_id.to_s
      else
        registrants_ids
      end
    end

    # this field is used for data export
    def export_id
        unless custom_external_id.nil?
            custom_external_id
        else
            if registrants.empty?
                nil
            else
                registrants.first.external_id
            end
        end
    end

    def age
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/member_count/#{members.size}/age") do
        if members.empty?
          "(No registrants)"
        else
          ages = registrants.map(&:age)
          ages.max
        end
      end
    end

    def country
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/member_count/#{members.size}/country") do
        if members.empty?
          "(No registrants)"
        else
          countries = registrants.map(&:country)
          # display all countries if there are more than 1 registrants
          if countries.uniq.count > 1
            countries.unique.join(",")
          else
            countries.uniq.first
          end
        end
      end
    end

    def gender
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/member_count/#{members.size}/gender") do
        if members.empty?
          "(No registrants)"
        else
          genders = registrants.map(&:gender)
          # display mixed if there are more than 1 registrants
          if genders.count > 1
            "(mixed)"
          else
            genders.first
          end
        end
      end
    end

    def wheel_size
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/member_count/#{members.size}/wheel_size_id") do
        if registrants.empty?
          nil
        else
          registrants.first.default_wheel_size.id
        end
      end
    end

    def ineligible
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/member_count/#{members.size}/ineligible") do
        if registrants.empty?
          false
        else
          eligibles = registrants.map(&:ineligible)
          if eligibles.uniq.count > 1
            true # includes both eligible status AND ineligible status
          else
            eligibles.first
          end
        end
      end
    end

    def club
      if registrants.empty?
        "(No registrants)"
      else
        registrants.first.club
      end
    end

    # for distance_attempt logic, there are certain 'states' that a competitor can get into
    def double_fault?
        if distance_attempts.count > 1
            if distance_attempts[0].fault == true && distance_attempts[1].fault == true
                return true
            end
        end

        false
    end

    def single_fault?
        if distance_attempts.count > 0
            distance_attempts.first.fault == true
        else
            false
        end
    end

    def max_attempted_distance
        distance_attempts.first.try(:distance) || 0
    end
    def max_successful_distance
        max_successful_distance_attempt.try(:distance) || 0
    end

    def max_successful_distance_attempt
        distance_attempts.where(:fault => false).first || nil
    end

    def status_code
        if distance_attempts.count == 0
            "can_attempt"
        else
            if double_fault?
                "double_fault"
            else
                if single_fault?
                    "single_fault"
                else
                    "can_attempt"
                end
            end
        end
    end

    def status
        if distance_attempts.count == 0
            "Not Attempted"
        else
            if double_fault?
                "Finished. Final Score #{max_successful_distance}"
            else
                if single_fault?
                    "Fault. Next Distance #{max_attempted_distance}+"
                else
                    "Success. Next Distance #{max_attempted_distance + 1}+"
                end
            end
        end
    end

    def is_top?(search_gender)
      return false if !has_result?
      return false if search_gender != gender

      overall_place.to_i <= 10
    end

    def self.group_selection_text
      "Create Pair/Group from selected Registrants"
    end
end
