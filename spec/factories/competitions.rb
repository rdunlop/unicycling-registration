# == Schema Information
#
# Table name: competitions
#
#  id                            :integer          not null, primary key
#  event_id                      :integer
#  name                          :string(255)
#  locked                        :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  age_group_type_id             :integer
#  has_experts                   :boolean          default(FALSE)
#  scoring_class                 :string(255)
#  start_data_type               :string(255)
#  end_data_type                 :string(255)
#  uses_lane_assignments         :boolean          default(FALSE)
#  scheduled_completion_at       :datetime
#  published                     :boolean          default(FALSE)
#  awarded                       :boolean          default(FALSE)
#  award_title_name              :string(255)
#  award_subtitle_name           :string(255)
#  num_members_per_competitor    :string(255)
#  automatic_competitor_creation :boolean          default(FALSE)
#  combined_competition_id       :integer
#  order_finalized               :boolean          default(FALSE)
#  penalty_seconds               :integer
#
# Indexes
#
#  index_competitions_event_id                    (event_id)
#  index_competitions_on_combined_competition_id  (combined_competition_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition do
    event # FactoryGirl
    sequence(:name) {|n| "Competition #{n}"}
    sequence(:award_title_name) {|n| "Competition #{n}"}
    locked false
    scoring_class "Freestyle"

    factory :distance_competition do
      scoring_class "High/Long"
      age_group_type # factory Girl
    end

    factory :street_competition do
      scoring_class "Street"
    end

    factory :flatland_competition do
      scoring_class "Flatland"
    end

    factory :timed_competition do
      scoring_class "Shortest Time"
      age_group_type # factory Girl
    end

    factory :slow_competition do
      scoring_class "Longest Time"
      age_group_type # factory Girl
    end

    factory :ranked_competition do
      scoring_class "Points Low to High"
      age_group_type # factory Girl
    end

    factory :high_points_competition do
      scoring_class "Points High to Low"
      age_group_type # factory Girl
    end
  end
end
