# == Schema Information
#
# Table name: competitions
#
#  id                :integer          not null, primary key
#  event_id          :integer
#  name              :string(255)
#  locked            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  age_group_type_id :integer
#  has_experts       :boolean          default(FALSE)
#  has_age_groups    :boolean          default(FALSE)
#  scoring_class     :string(255)
#  start_data_type   :string(255)
#  end_data_type     :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition do
    event # FactoryGirl
    sequence(:name) {|n| "Competition #{n}"}
    locked false
    scoring_class "Freestyle"

    factory :distance_competition do
      scoring_class "Two Attempt Distance"
    end

    factory :street_competition do
      scoring_class "Street"
    end

    factory :flatland_competition do
      scoring_class "Flatland"
    end

    factory :timed_competition do
      scoring_class "Distance"
    end

    factory :ranked_competition do
      scoring_class "Ranked"
    end
  end
end
