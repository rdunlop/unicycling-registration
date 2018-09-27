# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :payment_detail_summary do
    skip_create

    association(:line_item, factory: :expense_item) # FactoryBot
    payment # FactoryBot
    count { 1 }
    amount { 10.0 }
  end
end
