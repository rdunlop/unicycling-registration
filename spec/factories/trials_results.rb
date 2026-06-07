# == Schema Information
#
# Table name: trials_results
#
#  id            :bigint           not null, primary key
#  competitor_id :integer          not null
#  points        :integer          not null
#  minutes       :integer          not null
#  seconds       :integer          not null
#  details       :string
#  entered_at    :datetime         not null
#  entered_by_id :integer          not null
#  status        :string           not null
#  preliminary   :boolean          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_trials_results_on_competitor_id  (competitor_id) UNIQUE
#
# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :trials_result do
    association :competitor, factory: :event_competitor
    association :entered_by, factory: :user
    entered_at { Time.current }
    status { "active" }
    preliminary { false }
    points { 50 }
    minutes { 45 }
    seconds { 42 }
    details { "50 pts (45m 42s)" }
  end
end
