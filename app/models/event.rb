class Event < ActiveRecord::Base
  attr_accessible :category_id, :description, :name, :position

  has_many :event_choices, :order => "event_choices.position"
  belongs_to :category

  validates :name, :presence => true
  validates :category_id, :presence => true

  def to_s
    name
  end
end
