# == Schema Information
#
# Table name: competitors
#
#  id                 :integer          not null, primary key
#  competition_id     :integer
#  position           :integer
#  custom_external_id :integer
#  custom_name        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_competitor, :class => Competitor do
    competition  # FactoryGirl
    sequence(:position)
    after(:create) { |comp|
        FactoryGirl.create(:member, :competitor => comp)
        comp.reload
    }
  end

  factory :member, :class => Member do
    registrant
    association :competitor, :factory => :event_competitor
  end

end
