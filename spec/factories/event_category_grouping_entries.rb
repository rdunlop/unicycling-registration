FactoryBot.define do
  factory :event_category_grouping_entry do
    event_category_grouping
    event_category
  end
end

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
