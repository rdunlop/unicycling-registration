# == Schema Information
#
# Table name: event_choices
#
#  id                          :integer          not null, primary key
#  event_id                    :integer
#  cell_type                   :string(255)
#  multiple_values             :string(255)
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  optional                    :boolean          default(FALSE), not null
#  optional_if_event_choice_id :integer
#  required_if_event_choice_id :integer
#
# Indexes
#
#  index_event_choices_on_event_id_and_position  (event_id,position)
#

class EventChoice < ActiveRecord::Base
  belongs_to :event, touch: true, inverse_of: :event_choices, counter_cache: true

  has_many :registrant_choices, dependent: :destroy
  belongs_to :optional_if_event_choice, class_name: "EventChoice"
  belongs_to :required_if_event_choice, class_name: "EventChoice"

  validates :label, :cell_type, :event, presence: true

  translates :label, :tooltip, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  def self.cell_types
    ["boolean", "text"] # , "multiple", "best_time"]
  end

  validates :cell_type, inclusion: {in: cell_types }
  validates :optional, inclusion: {in: [true, false] } # because it's a boolean
  acts_as_restful_list scope: :event

  def choicename
    "choice#{id}"
  end

  def values
    multiple_values.split(%r{,\s*})
  end

  def unique_values
    registrant_choices.map{|rc| rc.value}.uniq
  end

  def to_s
    event.to_s + " - " + label
  end
end
