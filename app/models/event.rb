# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

class Event < ActiveRecord::Base
  resourcify

  has_many :event_choices, -> {order "event_choices.position"}, dependent: :destroy, inverse_of: :event
  accepts_nested_attributes_for :event_choices

  has_many :event_categories, -> { order "event_categories.position"}, dependent: :destroy, inverse_of: :event
  accepts_nested_attributes_for :event_categories

  has_many :registrant_event_sign_ups, dependent: :destroy, inverse_of: :event

  has_many :competitions, -> {order "competitions.name"}, dependent: :destroy, inverse_of: :event
  has_many :competitors, through: :competitions
  has_many :time_results, through: :competitors

  belongs_to :category, inverse_of: :events, touch: true
  has_many :songs

  acts_as_restful_list scope: :category

  def self.music_uploadable
    visible.where(accepts_music_uploads: true)
  end

  def self.visible
    where(visible: true)
  end

  def self.artistic
    where(artistic: true)
  end

  validates :name, presence: true
  validates :category_id, presence: true

  before_validation :build_event_category

  def build_event_category
    if event_categories.empty?
      event_categories.build name: "All"
    end
  end

  validate :has_event_category

  def has_event_category
    if event_categories.empty?
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

  def directors
    User.with_role(:director, self)
  end

  # determine the number of people who have signed up for this event
  def num_signed_up_registrants
    registrant_event_sign_ups.signed_up.count
  end

  def signed_up_registrants
    registrant_event_sign_ups.signed_up
  end

  def competitor_registrants
    competitors.map {|comp| comp.members.map{|mem| mem.registrant}}
  end

  def num_choices
    total = 1
    if event_categories.size > 1
      total += 1
    end
    if accepts_music_uploads?
      total += 1
    end
    total + event_choices.size
  end
end
