class TimeResult < ActiveRecord::Base
  belongs_to :competitor, :touch => true

  validates :minutes, :seconds, :thousands, :numericality => {:greater_than_or_equal_to => 0}
  validates :competitor_id, :presence => true, :uniqueness => true
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

    if thousands == 0
      # print no thousands
    else
      if thousands % 100 == 0
        thousands_string = ".#{(thousands / 100).to_s}"
      else
        thousands_string = ".#{thousands.to_s.rjust(3,"0")}"
      end
    end

    hours = minutes / 60
    if hours > 0
      remaining_minutes = minutes % 60
      "#{hours}:#{remaining_minutes.to_s.rjust(2,"0")}:#{seconds.to_s.rjust(2, "0")}#{thousands_string}"
    else
      "#{minutes}:#{seconds.to_s.rjust(2, "0")}#{thousands_string}"
    end
  end

  def full_time_in_thousands
    (minutes * 60000) + (seconds * 1000) + thousands
  end

  def is_top?(search_gender)
    return false if disqualified
    return false if search_gender != competitor.gender
    return competitor.overall_place.to_i <= 10
  end
end
