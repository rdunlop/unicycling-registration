# == Schema Information
#
# Table name: boundary_scores
#
#  id               :integer          not null, primary key
#  competitor_id    :integer
#  judge_id         :integer
#  number_of_people :integer
#  major_dismount   :integer
#  minor_dismount   :integer
#  major_boundary   :integer
#  minor_boundary   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_boundary_scores_competitor_id                  (competitor_id)
#  index_boundary_scores_judge_id                       (judge_id)
#  index_boundary_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :boundary_score do
    association :competitor, :factory => :event_competitor
    judge # FactoryGirl
    number_of_people 3
    major_dismount 0
    minor_dismount 0
    major_boundary 0
    minor_boundary 0
  end
end
