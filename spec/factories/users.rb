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

    factory :judge_user do
      after(:create) {|user| user.add_role :judge }
    end

    factory :chief_judge do
      after(:create) {|user| user.add_role :judge }
      after(:create) {|user| user.add_role :chief_judge, EventCategory }
    end

    after(:create) { |user| user.confirm! if ENV["MAIL_SKIP_CONFIRMATION"].nil? }
  end
end
