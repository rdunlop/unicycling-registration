# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  registrant_id      :integer
#  declined           :boolean          default(FALSE), not null
#  accepted_readonly  :boolean          default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  accepted_readwrite :boolean          default(FALSE), not null
#
# Indexes
#
#  ada_reg_user                                        (registrant_id,user_id) UNIQUE
#  index_additional_registrant_accesses_registrant_id  (registrant_id)
#  index_additional_registrant_accesses_user_id        (user_id)
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
