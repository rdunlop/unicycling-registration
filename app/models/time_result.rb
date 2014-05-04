# == Schema Information
#
# Table name: time_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  minutes       :integer
#  seconds       :integer
#  thousands     :integer
#  disqualified  :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TimeResult < ActiveRecord::Base
  include Competeable
  include Placeable

  validates :minutes, :seconds, :thousands, :numericality => {:greater_than_or_equal_to => 0}
  validates :competitor_id, :uniqueness => true
  validates :disqualified, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :is_start_time, :inclusion => { :in => [true, false] } # because it's a boolean

  scope :fastest_first, -> { order("disqualified, minutes, seconds, thousands") }

  after_initialize :init

  def init
    self.disqualified = false if self.disqualified.nil?
    self.is_start_time = false if self.is_start_time.nil?
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

  def thousands_string
    if thousands == 0
      # print no thousands
      ""
    else
      if thousands % 100 == 0
        thousands_string = ".#{(thousands / 100).to_s}"
      else
        thousands_string = ".#{thousands.to_s.rjust(3,"0")}"
      end
    end
  end

  def hours_minutes_string
    hours = minutes / 60
    if hours > 0
      remaining_minutes = minutes % 60
      "#{hours}:#{remaining_minutes.to_s.rjust(2,"0")}"
    else
      "#{minutes}"
    end
  end

  def seconds_string
    seconds.to_s.rjust(2, "0")
  end

  def full_time
    return "" if disqualified

    "#{hours_minutes_string}:#{seconds_string}#{thousands_string}"
  end

  def result
    full_time_in_thousands
  end

  def full_time_in_thousands
    (minutes * 60000) + (seconds * 1000) + thousands
  end
end
