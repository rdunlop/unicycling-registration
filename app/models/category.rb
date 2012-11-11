class Category < ActiveRecord::Base
  attr_accessible :name, :position

  has_many :events

  validates :name, :presence => true

  def to_s
    name
  end
end
