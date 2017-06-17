# == Schema Information
#
# Table name: registration_costs
#
#  id              :integer          not null, primary key
#  start_date      :date
#  end_date        :date
#  registrant_type :string           not null
#  onsite          :boolean          default(FALSE), not null
#  current_period  :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_registration_costs_on_current_period                      (current_period)
#  index_registration_costs_on_registrant_type_and_current_period  (registrant_type,current_period)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registration_cost do
    start_date Date.new(2012, 11, 3)
    end_date Date.new(2022, 11, 27)

    transient do
      build_entries true
      # if specified,we will build the first entry with this expense_item
      expense_item nil
    end

    trait :without_entries do
      build_entries false
    end

    after(:build) do |registration_cost, evaluator|
      if evaluator.build_entries
        registration_cost.registration_cost_entries << if evaluator.expense_item.nil?
                                                         build(:registration_cost_entry, registration_cost: registration_cost)
                                                       else
                                                         build(:registration_cost_entry, registration_cost: registration_cost, expense_item: evaluator.expense_item)
                                                       end
      end
    end
    sequence(:name) { |n| "Early Registration #{n}" }
    onsite false
    registrant_type "competitor"

    trait :current do
      current_period true
    end

    trait :competitor do
      registrant_type "competitor"
    end

    trait :noncompetitor do
      registrant_type "noncompetitor"
    end

    trait :spectator do
      registrant_type "spectator"
    end
  end
end
