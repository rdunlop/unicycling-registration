class EventChoice < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessible :cell_type, :event_id, :export_name, :label, :multiple_values, :position, :autocomplete, :optional, :tooltip, :optional_if_event_choice_id

  belongs_to :event, :touch => true
  has_many :registrant_choices, :dependent => :destroy
  belongs_to :optional_if_event_choice, :class_name => "EventChoice"

  validates :label, {:presence => true}
  validates :export_name, {:presence => true, :uniqueness => true}

  translates :label, :tooltip
  accepts_nested_attributes_for :translations
  attr_accessible :translations_attributes

  def self.cell_types
    ["boolean", "text", "multiple", "best_time"]
  end

  validates :cell_type, :inclusion => {:in => self.cell_types }
  validates :position, :uniqueness => {:scope => [:event_id]}
  validates :autocomplete, :inclusion => {:in => [true, false] } # because it's a boolean
  validates :optional, :inclusion => {:in => [true, false] } # because it's a boolean

  after_initialize :init

  def init
    self.autocomplete = false if self.autocomplete.nil?
    self.optional = false if self.optional.nil?
  end

  def choicename
    "choice#{id}"
  end

  def values
    multiple_values.split(%r{,\s*})
  end

  def unique_values
    self.registrant_choices.map{|rc| rc.value}.uniq
  end

  def to_s
    self.event.to_s + " - " + self.label
  end
end
