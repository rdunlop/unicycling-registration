# == Schema Information
#
# Table name: import_results
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  raw_data       :string(255)
#  bib_number     :integer
#  minutes        :integer
#  seconds        :integer
#  thousands      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competition_id :integer
#  rank           :integer
#  details        :string(255)
#  is_start_time  :boolean          default(FALSE)
#  attempt_number :integer
#  status         :string(255)
#  comments       :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_result do
    user # FactoryGirl
    competition # FactoryGirl
    raw_data "MyString"
    bib_number 1
    minutes 1
    seconds 1
    thousands 1
    status nil
  end
end
