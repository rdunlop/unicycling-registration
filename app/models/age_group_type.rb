class AgeGroupType < ActiveRecord::Base
  attr_accessible :name, :description

  validates :name, :presence => true

  has_many :age_group_entries, :dependent => :destroy

  def to_s
    name
  end
end
