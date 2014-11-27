# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string(255)
#  points        :decimal(6, 3)    not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_result do
    association :competitor, :factory => :event_competitor
    details "MyString"
    points 1
  end
end
