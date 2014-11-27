# == Schema Information
#
# Table name: registration_periods
#
#  id                            :integer          not null, primary key
#  start_date                    :date
#  end_date                      :date
#  name                          :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  competitor_expense_item_id    :integer
#  noncompetitor_expense_item_id :integer
#  onsite                        :boolean
#  current_period                :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_period do
    start_date Date.new(2012,11,03)
    end_date Date.new(2022,11,27)
    association :competitor_expense_item, factory: :expense_item, cost: 100
    association :noncompetitor_expense_item, factory: :expense_item, cost: 50
    name "Early Registration"
    onsite false

    trait :current do
      current_period true
    end
  end
end
