FactoryBot.define do
  factory :member, class: 'Member' do
    association(:registrant, factory: :registrant) # FactoryBot
    association :competitor, factory: :event_competitor
  end
end

# == Schema Information
#
# Table name: members
#
#  id                        :integer          not null, primary key
#  competitor_id             :integer
#  registrant_id             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  dropped_from_registration :boolean          default(FALSE), not null
#  alternate                 :boolean          default(FALSE), not null
#  registrant_type           :string
#
# Indexes
#
#  index_members_competitor_id  (competitor_id)
#  index_members_registrant_id  (registrant_id)
#
