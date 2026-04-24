# == Schema Information
#
# Table name: event_category_grouping_entries
#
#  id                         :bigint           not null, primary key
#  event_category_grouping_id :bigint
#  event_category_id          :bigint
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  ecge_event_category  (event_category_id)
#  ecge_grouping        (event_category_grouping_id)
#
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
