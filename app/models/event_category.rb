class EventCategory < ActiveRecord::Base
  belongs_to :event, :inverse_of => :event_categories, :touch => true
  belongs_to :age_group_type, :inverse_of => :event_categories

  has_many :registrant_event_sign_ups, :dependent => :destroy

  belongs_to :competition

  validates :name, {:presence => true, :uniqueness => {:scope => [:event_id]} }
  validates :position, :uniqueness => {:scope => [:event_id]}

  def to_s
    event.to_s + " - " + self.name
  end

  def signed_up_registrants
    registrant_event_sign_ups.where({:signed_up => true}).map{|resu| resu.registrant }.keep_if {|reg| !reg.nil?}
  end

  def num_competitors
    signed_up_registrants.count
  end

  def event_class
    event.event_class
  end
end
