# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "me#{n}@dunlopweb.com" }
    password "something"
    password_confirmation "something"

    factory :admin_user do
    end

    after(:create) { |user| user.confirm! }
  end
end
