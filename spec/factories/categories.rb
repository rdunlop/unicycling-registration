# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#  info_url   :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    sequence(:name) {|n| "TheCategory #{n}"}
    position 1
  end
end
