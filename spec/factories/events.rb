# == Schema Information
#
# Table name: events
#
#  id                    :integer          not null, primary key
#  category_id           :integer
#  export_name           :string(255)
#  position              :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  name                  :string(255)
#  visible               :boolean
#  accepts_music_uploads :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    category # FactoryGirl
    sequence(:name) {|n| "Teh event number #{n}" }
    export_name "SomeName"
    visible true
    position 1
  end
end
