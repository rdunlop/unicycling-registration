FactoryGirl.define do
  factory :expense_group_free_option do
    expense_group # FactoryGirl
    registrant_type "competitor"
    free_option "One Free In Group REQUIRED"
  end
end
