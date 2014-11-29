# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean
#  event_category_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  event_id          :integer
#
# Indexes
#
#  index_registrant_event_sign_ups_event_category_id              (event_category_id)
#  index_registrant_event_sign_ups_event_id                       (event_id)
#  index_registrant_event_sign_ups_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_registrant_event_sign_ups_registrant_id                  (registrant_id)
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
        if resu.event_category.nil?
          ev = FactoryGirl.create(:event)
          resu.event_category = ev.event_categories.first
        end
        resu.event = resu.event_category.event
      end
    end
  end
end
