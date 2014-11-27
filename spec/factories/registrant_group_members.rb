# == Schema Information
#
# Table name: registrant_group_members
#
#  id                  :integer          not null, primary key
#  registrant_id       :integer
#  registrant_group_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_registrant_group_mumbers_registrant_group_id  (registrant_group_id)
#  index_registrant_group_mumbers_registrant_id        (registrant_id)
#  reg_group_reg_group                                 (registrant_id,registrant_group_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_group_member do
    registrant_group # FactoryGirl
    registrant # FactoryGirl
  end
end
