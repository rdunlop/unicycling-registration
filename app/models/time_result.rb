class TimeResult < ActiveRecord::Base
  belongs_to :event_category, :touch => true
  belongs_to :registrant
  attr_accessible :disqualified, :minutes, :registrant_id, :seconds, :thousands, :event_category_id

  validates :minutes, :seconds, :thousands, :numericality => {:greater_than_or_equal_to => 0}
  validates :registrant_id, :presence => true, :uniqueness => {:scope => [:event_category_id]}
  validates :event_category, :presence => true
  validates :disqualified, :inclusion => { :in => [true, false] } # because it's a boolean

  after_initialize :init

  def init
    self.disqualified = false if self.disqualified.nil?
    self.minutes = 0 if self.minutes.nil?
    self.seconds = 0 if self.seconds.nil?
    self.thousands = 0 if self.thousands.nil?
  end

  def bib_number
    registrant.bib_number
  end
  def as_json(options={})
    options = {
      :except => [:id, :created_at, :updated_at, :registrant_id, :event_category_id],
      :methods => [:bib_number]
    }
    super(options)
  end

  def full_time
    return "" if disqualified

    hours = minutes / 60
    if hours > 0
      remaining_minutes = minutes % 60
      "#{hours}:#{remaining_minutes.to_s.rjust(2,"0")}:#{seconds.to_s.rjust(2, "0")}:#{thousands.to_s.rjust(3,"0")}"
    else
      "#{minutes}:#{seconds.to_s.rjust(2, "0")}:#{thousands.to_s.rjust(3,"0")}"
    end
  end

  def full_time_in_thousands
    (minutes * 60000) + (seconds * 1000) + thousands
  end

  def place=(place)
    Rails.cache.write(place_key, place)
  end

  def age_group_entry
    agt = event_category.age_group_type
    return nil if agt.nil?
    agt.age_group_entry_for(registrant.age, registrant.gender)
  end

  def age_group_entry_description
    ag_entry = age_group_entry
    if ag_entry.nil?
      "No Age Group for #{registrant.age}-#{registrant.gender}"
    else
      "#{ag_entry.start_age} - #{ag_entry.end_age}"
    end
  end

  def place
    return "DQ" if disqualified

    found_place = Rails.cache.fetch(place_key)
    if found_place.nil?
      calc = RaceCalculator.new(event_category, registrant.age, registrant.gender)
      calc.update_places
      found_place = Rails.cache.fetch(place_key)
    end

    found_place
  end

  private
  def place_key
    "/age_group_entry/#{age_group_entry_description}/event_category/#{event_category.id}-#{event_category.updated_at}/time_results/#{id}-#{updated_at}/place"
  end
end
