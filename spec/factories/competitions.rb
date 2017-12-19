# == Schema Information
#
# Table name: competitions
#
#  id                                    :integer          not null, primary key
#  event_id                              :integer
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  age_group_type_id                     :integer
#  has_experts                           :boolean          default(FALSE), not null
#  scoring_class                         :string(255)
#  start_data_type                       :string(255)
#  end_data_type                         :string(255)
#  uses_lane_assignments                 :boolean          default(FALSE), not null
#  scheduled_completion_at               :datetime
#  awarded                               :boolean          default(FALSE), not null
#  award_title_name                      :string(255)
#  award_subtitle_name                   :string(255)
#  num_members_per_competitor            :string(255)
#  automatic_competitor_creation         :boolean          default(FALSE), not null
#  combined_competition_id               :integer
#  order_finalized                       :boolean          default(FALSE), not null
#  penalty_seconds                       :integer
#  locked_at                             :datetime
#  published_at                          :datetime
#  sign_in_list_enabled                  :boolean          default(FALSE), not null
#  time_entry_columns                    :string           default("minutes_seconds_thousands")
#  import_results_into_other_competition :boolean          default(FALSE), not null
#  base_age_group_type_id                :integer
#  score_ineligible_competitors          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_competitions_event_id                    (event_id)
#  index_competitions_on_base_age_group_type_id   (base_age_group_type_id)
#  index_competitions_on_combined_competition_id  (combined_competition_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :competition do
    event # FactoryGirl
    sequence(:name) {|n| "Competition #{n}"}
    sequence(:award_title_name) {|n| "Competition #{n}"}
    locked_at nil
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

    factory :timed_laps_competition do
      scoring_class "Timed Multi-Lap"
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

    trait :standard_skill do
      scoring_class "Standard Skill"
    end

    trait :combined do
      scoring_class "Overall Champion"
      combined_competition # Factory Girl
    end

    trait :freestyle_2017 do
      scoring_class "Artistic Freestyle IUF 2017"
    end

    trait :locked do
      locked_at Time.current
    end

    trait :published do
      locked
      published_at Time.current
    end
  end
end
