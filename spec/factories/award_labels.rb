# == Schema Information
#
# Table name: award_labels
#
#  id            :integer          not null, primary key
#  bib_number    :integer
#  line_2        :string
#  line_3        :string
#  line_5        :string
#  place         :integer
#  user_id       :integer
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  line_1        :string
#  line_4        :string
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :award_label do
    bib_number { 1 }
    line_1 { "Bob Smith" }
    line_2 { "MyString" }
    # line_3 "Team Awesome"
    line_4 { "All" }
    line_5 { "MyString" }
    place { 1 }
    user # Factory Girl
    registrant # FactoryBot
  end
end
