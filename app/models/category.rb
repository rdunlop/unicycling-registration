# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  info_url   :string(255)
#

class Category < ActiveRecord::Base
  include CachedModel

  default_scope { order('position ASC') }

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
end
