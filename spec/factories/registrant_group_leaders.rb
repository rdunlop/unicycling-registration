# == Schema Information
#
# Table name: registrant_group_leaders
#
#  id                  :integer          not null, primary key
#  registrant_group_id :integer          not null
#  user_id             :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_registrant_group_leaders_on_registrant_group_id  (registrant_group_id)
#  index_registrant_group_leaders_on_user_id              (user_id)
#  registrant_group_leaders_uniq                          (registrant_group_id,user_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_group_leader do
    association :user, factory: :user
    association :registrant_group, factory: :registrant_group
  end
end
