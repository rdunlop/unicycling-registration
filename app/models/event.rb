class Event < ActiveRecord::Base
  attr_accessible :category_id, :description, :position, :event_choices_attributes, :name

  has_many :event_choices, :order => "event_choices.position", :dependent => :destroy
  accepts_nested_attributes_for :event_choices

  has_many :event_categories, :dependent => :destroy, :order => "position"

  belongs_to :category

  validates :name, :presence => true
  validates :category_id, :presence => true

  before_create :build_associated_event_choice

  def build_associated_event_choice
    self.event_choices.build({:position => 1, :cell_type => 'boolean', :label => "New Event", :export_name => "new_event_yn" })
  end

  def primary_choice
    event_choices.where({:position => 1}).first
  end

  # does this entry represent the Standard Skill event?
  def standard_skill?
    name == "Standard Skill"
  end

  def to_s
    name
  end

  # determine the number of people who have signed up for this event
  def num_competitors
    primary_choice.registrant_choices.where({:value => "1"}).count
  end
end
