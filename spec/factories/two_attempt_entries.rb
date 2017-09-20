# == Schema Information
#
# Table name: two_attempt_entries
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  competition_id :integer
#  bib_number     :integer
#  minutes_1      :integer
#  minutes_2      :integer
#  seconds_1      :integer
#  status_1       :string(255)      default("active")
#  seconds_2      :integer
#  thousands_1    :integer
#  thousands_2    :integer
#  status_2       :string(255)      default("active")
#  is_start_time  :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_two_attempt_entries_ids  (competition_id,is_start_time,id)
#

FactoryGirl.define do
  factory :two_attempt_entry do
    user # FactoryGirl
    competition # FactoryGirl
    bib_number 1
    minutes_1 1
    minutes_2 1
    seconds_1 2
    seconds_2 2
    thousands_1 3
    thousands_2 3
    status_1 "active"
    status_2 "active"
  end
end
