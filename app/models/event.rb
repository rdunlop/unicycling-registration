class Event < ActiveRecord::Base
  attr_accessible :category_id, :description, :name, :position

  has_many :event_choices, :order => "event_choices.position", :dependent => :destroy
  belongs_to :category

  validates :name, :presence => true
  validates :category_id, :presence => true

  before_create :build_associated_event_choice

  def build_associated_event_choice
    self.event_choices.build({:position => 1, :cell_type => 'boolean', :export_name => "#{self.name}_yn" })
  end

  def to_s
    name
  end
end
