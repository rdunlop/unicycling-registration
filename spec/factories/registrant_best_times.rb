# == Schema Information
#
# Table name: registrant_best_times
#
#  id              :integer          not null, primary key
#  event_id        :integer          not null
#  registrant_id   :integer          not null
#  source_location :string           not null
#  value           :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_registrant_best_times_on_event_id_and_registrant_id  (event_id,registrant_id) UNIQUE
#  index_registrant_best_times_on_registrant_id               (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_best_time do
    registrant
    event
    value 60000
    source_location "Nationals 2012"
  end
end
