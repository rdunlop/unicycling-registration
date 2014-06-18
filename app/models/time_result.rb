# == Schema Information
#
# Table name: time_results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  minutes        :integer
#  seconds        :integer
#  thousands      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  is_start_time  :boolean          default(FALSE)
#  attempt_number :integer
#  status         :string(255)
#  comments       :text
#  comments_by    :string(255)
#
# Indexes
#
#  index_time_results_on_event_category_id  (competitor_id)
#

class TimeResult < ActiveRecord::Base
  include Competeable
  include Placeable
  include StatusNilWhenEmpty

  validates :minutes, :seconds, :thousands, :numericality => {:greater_than_or_equal_to => 0}
  validates :competitor_id, :presence => true

  def self.status_values
    ["DQ"]
  end

  validates :status, :inclusion => { :in => TimeResult.status_values, :allow_nil => true }

  validates :is_start_time, :inclusion => { :in => [true, false] } # because it's a boolean

  scope :fastest_first, -> { order("status DESC, minutes, seconds, thousands") }
  scope :start_times, -> { where(:is_start_time => true) }
  scope :finish_times, -> { where(:is_start_time => false) }

  after_initialize :init

  def init
    self.is_start_time = false if self.is_start_time.nil?
    self.minutes = 0 if self.minutes.nil?
    self.seconds = 0 if self.seconds.nil?
    self.thousands = 0 if self.thousands.nil?
  end

  def disqualified
    status == "DQ"
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
