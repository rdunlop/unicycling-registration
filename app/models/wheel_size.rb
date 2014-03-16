class WheelSize < ActiveRecord::Base
  validates :position, :description, :presence => true

  default_scope { order("position ASC") }

  has_many :age_group_entries, :dependent => :nullify
  has_many :registrants, :dependent => :nullify


  def to_s
    description
  end
end
