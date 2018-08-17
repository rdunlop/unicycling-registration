# == Schema Information
#
# Table name: wave_times
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  wave           :integer
#  minutes        :integer
#  seconds        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  scheduled_time :string(255)
#
# Indexes
#
#  index_wave_times_on_competition_id_and_wave  (competition_id,wave) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :wave_time do
    competition # FactoryBot
    wave { 1 }
    minutes { 2 }
    seconds { 3 }
  end
end
