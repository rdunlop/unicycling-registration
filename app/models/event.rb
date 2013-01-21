class Event < ActiveRecord::Base
  attr_accessible :category_id, :description, :name, :position, :event_choices_attributes

  has_many :event_choices, :order => "event_choices.position", :dependent => :destroy
  accepts_nested_attributes_for :event_choices

  belongs_to :category

  validates :name, :presence => true
  validates :category_id, :presence => true

  before_create :build_associated_event_choice

  def build_associated_event_choice
    self.event_choices.build({:position => 1, :cell_type => 'boolean', :export_name => "#{self.name}_yn" })
  end

  def primary_choice
    event_choices.where({:position => 1}).first
  end

  def to_s
    name
  end

  # determine the number of people who have signed up for this event
  def num_competitors
    primary_choice.registrant_choices.where({:value => "1"}).count
  end
end
