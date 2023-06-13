class EventCategoryGroupingEntry < ApplicationRecord
  belongs_to :event_category_grouping
  belongs_to :event_category

  validates :event_category_id, uniqueness: { scope: [:event_category_grouping_id] }

  # If being created with a 'nil' event_category_grouping, automatically creates one
  before_validation :create_event_category_grouping
  around_destroy :delete_associated_event_category_grouping

  # If being deleted, and is the last one in an event_category_grouping, automatically deletes one

  private

  def create_event_category_grouping
    if event_category_grouping_id.blank?
      self.event_category_grouping = EventCategoryGrouping.create
    end
  end

  def delete_associated_event_category_grouping
    ecg = event_category_grouping
    yield
    if ecg.reload.event_category_grouping_entries.count.zero?
      ecg.destroy
    end
  end
end
