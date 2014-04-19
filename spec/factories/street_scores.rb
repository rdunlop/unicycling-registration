# == Schema Information
#
# Table name: street_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  judge_id      :integer
#  val_1         :decimal(5, 3)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :street_score do
    association :competitor, :factory => :event_competitor
    judge # use FactoryGirl
    val_1 0.0
  end
end
