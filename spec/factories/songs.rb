# == Schema Information
#
# Table name: songs
#
#  id             :integer          not null, primary key
#  registrant_id  :integer
#  description    :string(255)
#  song_file_name :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  event_id       :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :song do
    description "MyString"
    song_file_name "MyString"
    event
    registrant
    user
  end
end
