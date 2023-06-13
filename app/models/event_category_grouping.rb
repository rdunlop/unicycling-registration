class EventCategoryGrouping < ApplicationRecord
  has_many :event_category_grouping_entries, dependent: :restrict_with_error

  def to_s
    event_category_grouping_entries.map(&:event_category).map(&:to_s).join(", ")
  end
end
