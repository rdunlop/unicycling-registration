class EventCategory < ActiveRecord::Base
  belongs_to :event, :inverse_of => :event_categories, :touch => true

  has_many :registrant_event_sign_ups, :dependent => :destroy

  has_many :competitions

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

end
