# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "me#{n}@dunlopweb.com" }
    password "something"
    password_confirmation "something"
    admin false
    super_admin false

    factory :admin_user do
      admin true
    end
    factory :super_admin_user do
      super_admin true
    end

    after(:create) { |user| user.confirm! }
  end
end
