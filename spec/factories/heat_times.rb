# == Schema Information
#
# Table name: heat_times
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  minutes        :integer
#  seconds        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  scheduled_time :string(255)
#
# Indexes
#
#  index_heat_times_on_competition_id_and_heat  (competition_id,heat) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :heat_time do
    competition # FactoryGirl
    heat 1
    minutes 2
    seconds 3
  end
end
