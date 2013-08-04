class Competitor < ActiveRecord::Base
    has_many :members
    has_many :registrants, :through => :members, :order => "bib_number"
    belongs_to :competition
    acts_as_list :scope => :competition

    has_many :scores, :dependent => :destroy
    has_many :boundary_scores, :dependent => :destroy
    has_many :street_scores, :dependent => :destroy
    has_many :standard_execution_scores, :dependent => :destroy
    has_many :standard_difficulty_scores, :dependent => :destroy
    has_many :distance_attempts, :dependent => :destroy, :order => "distance DESC, id DESC"
    has_many :time_results, :dependent => :destroy
    has_many :external_results, :dependent => :destroy

    attr_accessible :competition_id, :position, :registrant_ids, :custom_external_id, :custom_name
    accepts_nested_attributes_for :registrants

    validates :competition_id, :presence => true
    validates_associated :members
    # not all competitor types require a position
    #validates :position, :presence => true,
                         #:numericality => {:only_integer => true, :greater_than => 0}

    after_touch(:touch_places)
    after_save(:touch_places)

    def touch_places
      # update the last time for the overall gender
      Rails.cache.increment(overall_key, 1)
      # invalidate the cache for age-group-entry entries
      Rails.cache.increment(age_group_key, 1)
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
      Rails.cache.fetch(place_key) || "Unknown"
    end

    def overall_place=(place)
      Rails.cache.write(overall_place_key, place)
    end

    def overall_place
      Rails.cache.fetch(overall_place_key) || "Unknown"
    end

    def age_group_entry_description # XXX combine with the other age_group function
      Rails.cache.fetch("/competitor/#{id}-#{updated_at}/competition/#{competition.id}-#{competition.updated_at}/age_group_entry_description") do
        registrant = members.first.try(:registrant)
        ag_entry_description = competition.get_age_group_entry_description(registrant.age, registrant.gender, registrant.default_wheel_size.id) unless registrant.nil?
      end
    end

    private
    def age_group_key
      "/competition/#{competition.id}-#{competition.updated_at}/age_group/#{age_group_entry_description}/version"
    end

    def overall_key
      "/competition/#{competition.id}-#{competition.updated_at}/gender/#{gender}/overall_version"
    end

    def place_key
      competition.reload
      "/competition/#{competition.id}-#{competition.updated_at}/competitor/#{id}-#{updated_at}/age_group_count/#{age_group_key}/place"
    end

    def overall_place_key
      "/competition/#{competition.id}-#{competition.updated_at}competitor/#{id}-#{updated_at}/overall_count/#{overall_key}/overall_place"
    end

    public
    def result
      case competition.event.event_class
      when "Two Attempt Distance"
        "#{max_successful_distance} cm"
      when "Distance"
        time_results.first.full_time
      when "External"
        external_results.first.details
      end
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
        unless custom_name.nil? or custom_name.empty?
            custom_name
        else
            if registrants.empty?
                "(No registrants)"
            else
                registrants.map(&:name).join(" - ")
            end
        end
    end

    def detailed_name
      registrants_names = registrants.map(&:name).join(" - ")
      name = registrants_names
      unless custom_name.nil? or custom_name.empty?
        name = custom_name + "(#{registrants_names})"
      end
      name
    end

    def external_id
        unless custom_external_id.nil? or custom_external_id == 0
            custom_external_id.to_s
        else
            if registrants.empty?
                "(No registrants)"
            else
                registrants.map(&:external_id).join(",")
            end
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
        if registrants.empty?
            "(No registrants)"
        else
            ages = registrants.map(&:age)
            if ages.min != ages.max
                ages.min.to_s + "-" + ages.max.to_s
            else
                ages.min.to_s
            end
        end
    end

    def gender
        if registrants.empty?
            "(No registrants)"
        else
            genders = registrants.map(&:gender)
            if genders.uniq.count > 1
                "(mixed)"
            else
                genders.first
            end
            #genders.reduce(genders.first){|value_so_far, current_value| value_so_far == current_value ? value_so_far : "(mixed)"}
        end
    end

    def wheel_size
      if registrants.empty?
        nil
      else
        registrants.first.default_wheel_size.id
      end
    end

    def ineligible
      if registrants.empty?
        false
      else
        eligibles = registrants.map(&:ineligible)
        if eligibles.uniq.count > 1
          true
        else
          eligibles.first
        end
      end
    end

    def club
      if registrants.empty?
        "(No registrants)"
      else
        club = registrants.first.club
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
end
