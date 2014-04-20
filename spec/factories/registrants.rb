# == Schema Information
#
# Table name: registrants
#
#  id                      :integer          not null, primary key
#  first_name              :string(255)
#  middle_initial          :string(255)
#  last_name               :string(255)
#  birthday                :date
#  gender                  :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#  competitor              :boolean
#  deleted                 :boolean
#  bib_number              :integer
#  wheel_size_id           :integer
#  age                     :integer
#  ineligible              :boolean          default(FALSE)
#  volunteer               :boolean
#  online_waiver_signature :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant do
    sequence(:first_name) {|n| "FirstMyString #{n}" }
    middle_initial "MMyString"
    last_name "LastMyString"
    birthday Date.new(1990,11,10)
    gender "Male"
    user # FactoryGirl
    competitor true
    ineligible false
    contact_detail # FactoryGirl

    factory :competitor do
      competitor true
    end
    factory :noncompetitor do
      competitor false
    end

    factory :minor_competitor do
      competitor true
      before(:create) do |reg|
        reg.contact_detail.responsible_adult_name = "Bob Smith"
        reg.contact_detail.responsible_adult_phone = "911"
      end
    end
    before(:create) do
      if WheelSize.count == 0
        @ws20 = FactoryGirl.create(:wheel_size_20)
        @ws24 = FactoryGirl.create(:wheel_size_24)
      end
    end
    after :stub do |reg|
      ws = WheelSize.find_by(:description => "24\" Wheel")
      if ws.present?
        reg.default_wheel_size = ws
      end
    end
  end
end
