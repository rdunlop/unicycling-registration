class EventCategoryGrouping < ApplicationRecord
  has_many :event_category_grouping_entries, dependent: :restrict_with_error

  has_many :event_categories, through: :event_category_grouping_entries

  def to_s
    event_category_grouping_entries.map(&:event_category).map(&:to_s).join(", ")
  end
end
