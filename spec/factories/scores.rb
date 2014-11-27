# == Schema Information
#
# Table name: scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  val_1         :decimal(5, 3)
#  val_2         :decimal(5, 3)
#  val_3         :decimal(5, 3)
#  val_4         :decimal(5, 3)
#  notes         :text
#  judge_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_scores_competitor_id                  (competitor_id)
#  index_scores_judge_id                       (judge_id)
#  index_scores_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :score do
    association :competitor, :factory => :event_competitor
    judge
    val_1 1.1
    val_2 1.2
    val_3 1.3
    val_4 1.4
    notes 'this is a factory score'
  end
end
