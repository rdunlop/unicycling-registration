# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#  info_url   :string(255)
#

class Category < ActiveRecord::Base
  include CachedModel

  default_scope { order(:position) }

  has_many :events, -> {order("events.position") }, :dependent => :destroy, :inverse_of => :category

  validates :name, :presence => true

  translates :name
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
end
