# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_item do
    name "T-Shirt (S)"
    description "TShirt Small"
    cost "9.99"
    export_name "t_shirt_small"
    position 1
    expense_group # FactoryGirl
  end
end
