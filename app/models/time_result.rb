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
  validates :competitor_id, :presence => true
  validates :disqualified, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :is_start_time, :inclusion => { :in => [true, false] } # because it's a boolean

  scope :fastest_first, -> { order("disqualified, minutes, seconds, thousands") }
  scope :start_times, -> { where(:is_start_time => true) }
  scope :finish_times, -> { where(:is_start_time => false) }

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

  def full_time
    return "" if disqualified

    TimeResultPresenter.new(full_time_in_thousands).full_time
  end

  def result
    full_time_in_thousands
  end

  def full_time_in_thousands
    (minutes * 60000) + (seconds * 1000) + thousands
  end
end
