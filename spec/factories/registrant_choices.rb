# == Schema Information
#
# Table name: registrant_choices
#
#  id              :integer          not null, primary key
#  registrant_id   :integer
#  event_choice_id :integer
#  value           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_registrant_choices_event_choice_id                       (event_choice_id)
#  index_registrant_choices_on_registrant_id_and_event_choice_id  (registrant_id,event_choice_id) UNIQUE
#  index_registrant_choices_registrant_id                         (registrant_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant_choice do
    registrant # FactoryGirl
    event_choice # FactoryGirl
    value "0"
  end
end
