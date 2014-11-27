# == Schema Information
#
# Table name: judges
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  judge_type_id  :integer
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_judges_event_category_id                                (competition_id)
#  index_judges_judge_type_id                                    (judge_type_id)
#  index_judges_on_judge_type_id_and_competition_id_and_user_id  (judge_type_id,competition_id,user_id) UNIQUE
#  index_judges_user_id                                          (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :judge do
    competition
    judge_type # Use FactoryGirl to create
    user       # Use FactoryGirl to create
  end
end
