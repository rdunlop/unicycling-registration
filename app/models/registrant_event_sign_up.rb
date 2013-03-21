class RegistrantEventSignUp < ActiveRecord::Base
  attr_accessible :event_category_id, :registrant_id, :signed_up, :event_id

  validates :event, :presence => true
  #validates :event_category, :presence => true, :if  => "signed_up"
  validates :registrant, :presence => true
  validates :signed_up, :inclusion => {:in => [true, false] } # because it's a boolean
  validate :category_chosen_when_signed_up

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  belongs_to :registrant, :inverse_of => :registrant_event_sign_ups
  belongs_to :event_category
  belongs_to :event

  def category_chosen_when_signed_up
    if self.signed_up and self.event_category.nil?
      errors[:base] << "Cannot sign up for #{self.event.name} without choosing a category"
      errors[:signed_up] = ""
      errors[:event_category_id] = ""
    end
  end

  def to_s
    self.event_category.to_s
  end
end
