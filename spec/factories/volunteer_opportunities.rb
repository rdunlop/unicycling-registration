# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :volunteer_opportunity do
    sequence(:description) { |n| "Artistic Judge #{n}" }
    display_order 1
    inform_emails "test@dunlopweb.com"
  end
end

# == Schema Information
#
# Table name: volunteer_opportunities
#
#  id            :integer          not null, primary key
#  description   :string(255)
#  display_order :integer
#  inform_emails :text
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_volunteer_opportunities_on_description    (description) UNIQUE
#  index_volunteer_opportunities_on_display_order  (display_order)
#
