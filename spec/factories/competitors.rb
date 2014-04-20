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

require 'rspec/mocks/standalone'

FactoryGirl.define do
  factory :event_competitor, :class => Competitor do
    competition  # FactoryGirl
    sequence(:position)
    after(:create) do |comp|
      FactoryGirl.create(:member, :competitor => comp)
      comp.reload
    end
    after(:stub) do |competitor|
      allow(competitor).to receive(:members).and_return([FactoryGirl.build_stubbed(:member, :competitor => competitor)])
    end
  end

  factory :member, :class => Member do
    registrant
    association :competitor, :factory => :event_competitor
  end

end
