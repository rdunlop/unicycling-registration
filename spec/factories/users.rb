# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "me#{n}@dunlopweb.com" }
    password "something"
    password_confirmation "something"

    factory :admin_user do
      after(:create) {|user| user.add_role :admin }
    end
    factory :super_admin_user do
      after(:create) {|user| user.add_role :super_admin }
    end

    after(:create) { |user| user.confirm! }
  end
end
