# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean
#  event_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  event_id          :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_event_sign_up do
    registrant # FactoryGirl
    event nil
    event_category nil
    signed_up true

    before(:create) do |resu| 
      if resu.event.nil?
        ev = FactoryGirl.create(:event)
        resu.event = ev
        resu.event_category = ev.event_categories.first
      end
    end
  end
end
