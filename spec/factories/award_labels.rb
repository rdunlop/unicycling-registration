# == Schema Information
#
# Table name: award_labels
#
#  id            :integer          not null, primary key
#  bib_number    :integer
#  line_2        :string(255)
#  line_3        :string(255)
#  line_5        :string(255)
#  place         :integer
#  user_id       :integer
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  line_1        :string(255)
#  line_4        :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :award_label do
    bib_number 1
    line_1 "Bob Smith"
    line_2 "MyString"
    # line_3 "Team Awesome"
    line_4 "All"
    line_5 "MyString"
    place 1
    user # Factory Girl
    registrant # FactoryGirl
  end
end
