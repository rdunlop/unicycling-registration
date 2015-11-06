# == Schema Information
#
# Table name: categories
#
#  id           :integer          not null, primary key
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  info_url     :string(255)
#  info_page_id :integer
#

class Category < ActiveRecord::Base
  include CachedModel

  acts_as_restful_list
  default_scope { order(:position) }

  has_many :events, -> {order("events.position") }, dependent: :destroy, inverse_of: :category
  belongs_to :info_page, class_name: "Page"

  validates :name, presence: true
  validate :only_one_info_type

  translates :name, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  after_save(:touch_event_configuration)
  after_touch(:touch_event_configuration)

  def touch_event_configuration
    EventConfiguration.first.try(:touch)
  end

  def to_s
    name
  end

  def max_number_of_event_choices
    Rails.cache.fetch("/categories/#{id}-#{updated_at}/number_of_event_choices") do
      events.map(&:num_choices).max
    end
  end

  # load all the dependent models necessary to display the event-choices form efficiently
  def self.load_for_form
    includes(:translations, events: [event_choices: :translations, event_categories: []])
  end

  def additional_info?
    info_url.present? || info_page.present?
  end

  private

  def only_one_info_type
    if info_url.present? && info_page.present?
      errors[:info_page_id] << "Unable to specify both Info URL and Info Page"
    end
  end
end
