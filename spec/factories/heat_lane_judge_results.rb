FactoryGirl.define do
  factory :heat_lane_judge_note do
    competition
    heat 1
    lane 1
    association :entered_by, factory: :user
    entered_at { Time.current }
    status "active"
  end
end
