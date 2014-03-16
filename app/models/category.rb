class Category < ActiveRecord::Base
  default_scope { order('position ASC') }

  has_many :events, -> {order("events.position").includes(:event_choices) }, :dependent => :destroy, :inverse_of => :category

  validates :name, :presence => true

  translates :name
  accepts_nested_attributes_for :translations

  def to_s
    name
  end

  def max_number_of_event_choices
    Rails.cache.fetch("/categories/#{id}-#{updated_at}/number_of_event_choices") do
      events.map(&:num_choices).max
    end
  end
end
