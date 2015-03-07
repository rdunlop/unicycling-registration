# == Schema Information
#
# Table name: expense_groups
#
#  id                         :integer          not null, primary key
#  group_name                 :string(255)
#  visible                    :boolean
#  position                   :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  info_url                   :string(255)
#  competitor_free_options    :string(255)
#  noncompetitor_free_options :string(255)
#  competitor_required        :boolean          default(FALSE)
#  noncompetitor_required     :boolean          default(FALSE)
#  registration_items         :boolean          default(FALSE), not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :expense_group do
    group_name "MyString"
    visible true
    position 1
    competitor_required false
    noncompetitor_required false

    trait :registration do
      registration_items true
    end
  end
end
