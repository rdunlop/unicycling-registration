class EventCategory < ActiveRecord::Base
  attr_accessible :name, :event_id, :position

  belongs_to :event

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }
  validates :position, :uniqueness => {:scope => [:event_id]}

  def to_s
    self.name
  end
end
