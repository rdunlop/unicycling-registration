# == Schema Information
#
# Table name: award_labels
#
#  id               :integer          not null, primary key
#  bib_number       :integer
#  competition_name :string(255)
#  team_name        :string(255)
#  details          :string(255)
#  place            :integer
#  user_id          :integer
#  registrant_id    :integer
#  created_at       :datetime
#  updated_at       :datetime
#  competitor_name  :string(255)
#  category         :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :award_label do
    bib_number 1
    competitor_name "Bob Smith"
    competition_name "MyString"
    category "All"
    details "MyString"
    place 1
    user #Factory Girl
    registrant # FactoryGirl
  end
end
