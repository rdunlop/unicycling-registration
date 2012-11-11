class Category < ActiveRecord::Base
  attr_accessible :name, :position

  validates :name, :presence => true
end
