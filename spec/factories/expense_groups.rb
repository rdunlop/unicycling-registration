# == Schema Information
#
# Table name: expense_groups
#
#  id                     :integer          not null, primary key
#  visible                :boolean          default(TRUE), not null
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  info_url               :string
#  competitor_required    :boolean          default(FALSE), not null
#  noncompetitor_required :boolean          default(FALSE), not null
#  registration_items     :boolean          default(FALSE), not null
#  info_page_id           :integer
#  system_managed         :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :expense_group do
    group_name { "MyString" }
    visible { true }
    competitor_required { false }
    noncompetitor_required { false }

    trait :registration do
      system_managed { true }
      registration_items { true }
    end
  end
end
