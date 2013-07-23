class TimeResult < ActiveRecord::Base
  belongs_to :competitor, :touch => true
  attr_accessible :disqualified, :minutes, :seconds, :thousands, :competitor_id

  validates :minutes, :seconds, :thousands, :numericality => {:greater_than_or_equal_to => 0}
  validates :competitor_id, {:presence => true, :uniqueness => false }
  validates :disqualified, :inclusion => { :in => [true, false] } # because it's a boolean

  scope :fastest_first, order("disqualified, minutes, seconds, thousands")

  after_initialize :init

  def init
    self.disqualified = false if self.disqualified.nil?
    self.minutes = 0 if self.minutes.nil?
    self.seconds = 0 if self.seconds.nil?
    self.thousands = 0 if self.thousands.nil?
  end

  def as_json(options={})
    options = {
      :except => [:id, :created_at, :updated_at, :competitor_id],
      :methods => [:bib_number]
    }
    super(options)
  end

  def bib_number
    competitor.members.first.registrant.bib_number
  end

  def event
    competitor.event
  end

  def competition
    competitor.competition
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


  def age_group_entry_description
    registrant = competitor.members.first.registrant
    ag_entry_description = competitor.competition.age_group_type.try(:age_group_entry_description, registrant.age, registrant.gender, registrant.default_wheel_size.id)
    if ag_entry_description.nil?
      "No Age Group for #{registrant.age}-#{registrant.gender}"
    else
      ag_entry_description
    end
  end

  def place=(place)
    Rails.cache.write(place_key, place)
  end

  def place
    return "DQ" if disqualified

    Rails.cache.fetch(place_key) || "Unknown"
  end

  private
  def place_key
    "/competition/#{competition.id}/time_results/#{id}-#{updated_at}/place"
  end
end
