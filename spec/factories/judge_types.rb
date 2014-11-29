# == Schema Information
#
# Table name: judge_types
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  val_1_description            :string(255)
#  val_2_description            :string(255)
#  val_3_description            :string(255)
#  val_4_description            :string(255)
#  val_1_max                    :integer
#  val_2_max                    :integer
#  val_3_max                    :integer
#  val_4_max                    :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  event_class                  :string(255)
#  boundary_calculation_enabled :boolean
#
# Indexes
#
#  index_judge_types_on_name  (name) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :judge_type do
    sequence(:name) { |n| "Presentation #{n}" }
    event_class "Freestyle"

    val_1_description "Mistakes"
    val_2_description "Intepretation"
    val_3_description "Mastery"
    val_4_description "Magic"
    val_1_max 10
    val_2_max 10
    val_3_max 10
    val_4_max 10
    boundary_calculation_enabled false
  end
end
