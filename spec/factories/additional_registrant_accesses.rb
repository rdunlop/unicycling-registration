# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  registrant_id     :integer
#  declined          :boolean
#  accepted_readonly :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :additional_registrant_access do
    user # FactoryGirl
    registrant # FactoryGirl
    declined false
    accepted_readonly false
  end
end
