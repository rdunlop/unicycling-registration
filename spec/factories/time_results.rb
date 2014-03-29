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
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_result do
    competitor { FactoryGirl.create(:event_competitor) }
    disqualified false
    minutes 0
    seconds 0
    thousands 0
  end
end
