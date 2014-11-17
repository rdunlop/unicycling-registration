# == Schema Information
#
# Table name: tie_break_adjustments
#
#  id              :integer          not null, primary key
#  tie_break_place :integer
#  judge_id        :integer
#  competitor_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_tie_break_adjustments_competitor_id                  (competitor_id)
#  index_tie_break_adjustments_judge_id                       (judge_id)
#  index_tie_break_adjustments_on_competitor_id               (competitor_id) UNIQUE
#  index_tie_break_adjustments_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tie_break_adjustment do
    association :competitor, :factory => :event_competitor
    judge      # use FactoryGirl to create
    tie_break_place 1
  end
end
