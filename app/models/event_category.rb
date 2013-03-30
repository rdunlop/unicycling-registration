class EventCategory < ActiveRecord::Base
  has_many :time_results
  attr_accessible :name, :event_id, :position, :age_group_type_id

  belongs_to :event, :inverse_of => :event_categories
  belongs_to :age_group_type
  has_many :registrant_event_sign_ups, :dependent => :destroy

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }
  validates :position, :uniqueness => {:scope => [:event_id]}

  def to_s
    self.name
  end
end
