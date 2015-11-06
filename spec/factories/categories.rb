# == Schema Information
#
# Table name: categories
#
#  id           :integer          not null, primary key
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  info_url     :string(255)
#  info_page_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    sequence(:name) {|n| "TheCategory #{n}"}
  end
end
