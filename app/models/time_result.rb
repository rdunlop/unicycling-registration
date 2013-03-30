class TimeResult < ActiveRecord::Base
  belongs_to :event_category
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
end
