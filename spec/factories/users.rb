# == Schema Information
#
# Table name: public.users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string
#  guest                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "me#{n}@dunlopweb.com" }
    password { "something" }
    password_confirmation { "something" }

    factory :super_admin_user do
      after(:create) { |user| user.add_role :super_admin }
    end

    factory :convention_admin_user do
      after(:create) { |user| user.add_role :convention_admin }
    end

    factory :competition_admin_user do
      after(:create) { |user| user.add_role :competition_admin }
    end

    factory :award_admin_user do
      after(:create) { |user| user.add_role :awards_admin }
    end

    factory :data_entry_volunteer_user do
      after(:create) { |user| user.add_role :data_entry_volunteer }
    end

    factory :payment_admin do
      after(:create) { |user| user.add_role :payment_admin }
    end

    factory :director do
      after(:create) { |user| user.add_role :data_entry_volunteer }

      after(:create) { |user| user.add_role :director, EventCategory }
    end

    factory :music_dj do
      after(:create) { |user| user.add_role :music_dj }
    end

    factory :event_planner do
      after(:create) { |user| user.add_role :event_planner }
    end

    after(:create) { |user| user.confirm if Rails.configuration.mail_skip_confirmation }

    after(:create) { |user| user.user_conventions.create(subdomain: Tenant.first.subdomain) }
  end
end
