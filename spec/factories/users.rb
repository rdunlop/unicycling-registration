# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#

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

    factory :data_entry_volunteer_user do
      after(:create) {|user| user.add_role :data_entry_volunteer }
    end

    factory :payment_admin do
      after(:create) { |user| user.add_role :payment_admin }
    end

    factory :director do
      after(:create) {|user| user.add_role :data_entry_volunteer }
      after(:create) {|user| user.add_role :director, EventCategory }
    end

    after(:create) { |user| user.confirm! if ENV["MAIL_SKIP_CONFIRMATION"].nil? }
  end
end
