class Category < ActiveRecord::Base
  attr_accessible :name, :position

  has_many :events, :order => "events.position", :dependent => :destroy

  validates :name, :presence => true

  def to_s
    name
  end
end
