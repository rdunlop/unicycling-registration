# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  cell_type                   :string(255)
#  multiple_values             :string(255)
#  label                       :string(255)
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  autocomplete                :boolean
#  optional                    :boolean          default(FALSE)
#  tooltip                     :string(255)
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#
# Indexes
#
#  index_event_choices_on_event_id_and_position  (event_id,position) UNIQUE
#

class EventChoice < ActiveRecord::Base
  belongs_to :event, :touch => true, inverse_of: :event_choices, counter_cache: true

  has_many :registrant_choices, :dependent => :destroy
  belongs_to :optional_if_event_choice, :class_name => "EventChoice"
  belongs_to :required_if_event_choice, :class_name => "EventChoice"

  validates :label, {:presence => true}

  translates :label, :tooltip, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

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
