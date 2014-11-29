# == Schema Information
#
# Table name: time_results
#
#  id                  :integer          not null, primary key
#  competitor_id       :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  is_start_time       :boolean          default(FALSE)
#  number_of_laps      :integer
#  status              :string(255)
#  comments            :text
#  comments_by         :string(255)
#  number_of_penalties :integer
#  entered_at          :datetime
#
# Indexes
#
#  index_time_results_on_competitor_id  (competitor_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_result do
    association :competitor, :factory => :event_competitor
    status nil
    is_start_time false
    minutes 0
    seconds 0
    thousands 0
  end
end
