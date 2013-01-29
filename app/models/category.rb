class Category < ActiveRecord::Base
  attr_accessible :name, :position

  default_scope order('position ASC')

  has_many :events, :order => "events.position", :dependent => :destroy, :include => :event_choices

  validates :name, :presence => true

  def to_s
    name
  end
end
