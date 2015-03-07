# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE)
#  artistic                    :boolean          default(FALSE)
#  accepts_wheel_size_override :boolean          default(FALSE)
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    category # FactoryGirl
    sequence(:name) {|n| "Teh event number #{n}" }
    visible true
    position 1
  end
end
