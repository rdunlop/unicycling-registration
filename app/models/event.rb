# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#  best_time_format            :string           default("none"), not null
#  standard_skill              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

class Event < ApplicationRecord
  include CostItem
  resourcify

  with_options dependent: :destroy, inverse_of: :event do
    has_many :event_choices, -> {order "event_choices.position"}
    has_many :event_categories, -> { order "event_categories.position"}
    has_many :registrant_event_sign_ups
    has_many :competitions, -> {order "competitions.name"}
  end

  has_many :competitors, through: :competitions
  has_many :time_results, through: :competitors

  belongs_to :category, inverse_of: :events, touch: true
  has_many :songs

  translates :name, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :event_choices
  accepts_nested_attributes_for :event_categories
  accepts_nested_attributes_for :translations

  acts_as_restful_list scope: :category

  validates :name, presence: true
  validates :category_id, presence: true

  # include translations So that we can do Event.order(:name)
  default_scope { includes(:translations) }

  BEST_TIME_FORMATS = [
    "none",
    "h:mm",
    "(m)m:ss.xx"
  ].freeze

  validates :best_time_format, presence: true, inclusion: BEST_TIME_FORMATS

  def best_time?
    best_time_format != "none"
  end

  before_validation :build_event_category

  validate :has_event_category

  def self.music_uploadable
    visible.where(accepts_music_uploads: true)
  end

  def self.visible
    where(visible: true)
  end

  def self.artistic
    where(artistic: true)
  end

  def self.standard_skill_events
    where(standard_skill: true)
  end

  def to_s
    name
  end

  def directors
    User.this_tenant.with_role(:director, self)
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
    if best_time?
      total += 1
    end
    total + event_choices.size
  end

  # Creates RegistrantExpenseItems for any registrant
  # who has signed up for this event
  def create_for_all_registrants
    signed_up_registrants.each do |registrant_sign_up|
      registrant_sign_up.create_reg_item
    end
  end

  private

  def build_event_category
    if event_categories.empty?
      event_categories.build name: "All"
    end
  end

  def has_event_category
    if event_categories.empty?
      errors.add(:base, "Must define an event category")
    end
  end
end
