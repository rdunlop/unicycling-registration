# == Schema Information
#
# Table name: registration_periods
#
#  id                            :integer          not null, primary key
#  start_date                    :date
#  end_date                      :date
#  created_at                    :datetime
#  updated_at                    :datetime
#  competitor_expense_item_id    :integer
#  noncompetitor_expense_item_id :integer
#  onsite                        :boolean          default(FALSE), not null
#  current_period                :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_period do
    start_date Date.new(2012, 11, 03)
    end_date Date.new(2022, 11, 27)
    association :competitor_expense_item, factory: :expense_item, cost: 100
    association :noncompetitor_expense_item, factory: :expense_item, cost: 50
    name "Early Registration"
    onsite false

    trait :current do
      current_period true
    end
  end
end
