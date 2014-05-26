# == Schema Information
#
# Table name: time_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  minutes       :integer
#  seconds       :integer
#  thousands     :integer
#  disqualified  :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_start_time :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_result do
    association :competitor, :factory => :event_competitor
    disqualified false
    is_start_time false
    minutes 0
    seconds 0
    thousands 0
  end
end
