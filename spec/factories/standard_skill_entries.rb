# == Schema Information
#
# Table name: standard_skill_entries
#
#  id                        :integer          not null, primary key
#  number                    :integer
#  letter                    :string
#  points                    :decimal(6, 2)
#  description               :string
#  created_at                :datetime
#  updated_at                :datetime
#  friendly_description      :text
#  additional_description_id :integer
#  skill_speed               :string
#  skill_before_id           :integer
#  skill_after_id            :integer
#
# Indexes
#
#  index_standard_skill_entries_on_letter_and_number  (letter,number) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :standard_skill_entry do
    sequence(:number)
    sequence(:letter) do |n|
      x = "a"
      n.times do |_i|
        x = x.next
      end
      x
    end
    points { "1.3" }
    description { "riding - 8" }
  end
end
