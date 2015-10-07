# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_pages_on_slug  (slug) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do
    sequence(:slug) {|n| "page-#{n}"}
    title "Page Title"
    body "Page Body"
  end
end
