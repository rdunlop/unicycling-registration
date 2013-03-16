class AgeGroupType < ActiveRecord::Base
  attr_accessible :name, :description

  validates :name, :presence => true

  def to_s
    name
  end
end
