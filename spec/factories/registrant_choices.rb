# == Schema Information
#
# Table name: registrant_choices
#
#  id              :integer          not null, primary key
#  registrant_id   :integer
#  event_choice_id :integer
#  value           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_registrant_choices_event_choice_id                       (event_choice_id)
#  index_registrant_choices_on_registrant_id_and_event_choice_id  (registrant_id,event_choice_id) UNIQUE
#  index_registrant_choices_registrant_id                         (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :registrant_choice do
    registrant # FactoryBot
    event_choice # FactoryBot
    value "0"
  end
end
