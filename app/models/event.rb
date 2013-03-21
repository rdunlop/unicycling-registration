class Event < ActiveRecord::Base
  attr_accessible :category_id, :description, :position, :event_choices_attributes, :name

  has_many :event_choices, :order => "event_choices.position", :dependent => :destroy
  accepts_nested_attributes_for :event_choices

  has_many :event_categories, :dependent => :destroy, :order => "position", :inverse_of => :event
  accepts_nested_attributes_for :event_categories
  attr_accessible :event_categories_attributes

  has_many :registrant_event_sign_ups, :dependent => :destroy, :inverse_of => :event

  belongs_to :category, :inverse_of => :events

  validates :name, :presence => true
  validates :category_id, :presence => true

  before_validation :build_event_category


  def build_event_category
    if self.event_categories.empty?
      self.event_categories.build({:name => "All", :position => 1})
    end
  end

  validate :has_event_category

  def has_event_category
    if self.event_categories.empty?
      errors[:base] << "Must define an event category"
    end
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
    registrant_event_sign_ups.where({:signed_up => true}).count
  end
end
