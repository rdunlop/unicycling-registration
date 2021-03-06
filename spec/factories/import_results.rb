# == Schema Information
#
# Table name: import_results
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  raw_data            :string
#  bib_number          :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  competition_id      :integer
#  points              :decimal(6, 3)
#  details             :string
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string
#  comments            :text
#  comments_by         :string
#  heat                :integer
#  lane                :integer
#  number_of_penalties :integer
#
# Indexes
#
#  index_import_results_on_user_id  (user_id)
#  index_imported_results_user_id   (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :import_result do
    user # FactoryBot
    competition # FactoryBot
    raw_data { "MyString" }
    bib_number { 1 }
    minutes { 1 }
    seconds { 1 }
    thousands { 1 }
    status { nil }
  end
end
