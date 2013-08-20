class Category < ActiveRecord::Base
  attr_accessible :name, :position, :info_url

  default_scope order('position ASC')

  has_many :events, :order => "events.position", :dependent => :destroy, :include => :event_choices, :inverse_of => :category

  validates :name, :presence => true

  def to_s
    name
  end

  def max_number_of_event_choices
    Rails.cache.fetch("/categories/#{id}-#{updated_at}/number_of_event_choices") do
      events.map(&:num_choices).max
    end
  end
end
