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
#  created_at              :datetime
#  updated_at              :datetime
#  user_id                 :integer
#  deleted                 :boolean          default(FALSE), not null
#  bib_number              :integer
#  wheel_size_id           :integer
#  age                     :integer
#  ineligible              :boolean          default(FALSE), not null
#  volunteer               :boolean          default(FALSE), not null
#  online_waiver_signature :string(255)
#  access_code             :string(255)
#  sorted_last_name        :string(255)
#  status                  :string(255)      default("active"), not null
#  registrant_type         :string(255)      default("competitor")
#  rules_accepted          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registrant do
    sequence(:first_name) {|n| "FirstMyString #{n}" }
    middle_initial "MMyString"
    last_name "LastMyString"
    birthday Date.new(1990, 11, 10)
    gender "Male"
    user # FactoryGirl
    registrant_type 'competitor'
    ineligible false
    contact_detail # FactoryGirl

    factory :competitor do
      registrant_type 'competitor'
    end
    factory :noncompetitor do
      registrant_type 'noncompetitor'
    end
    factory :spectator do
      registrant_type 'spectator'
    end

    factory :minor_competitor, parent: :competitor do
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
      reg.bib_number ||= 1234
      ws = WheelSize.find_by(description: "24\" Wheel")
      if ws.present?
        reg.default_wheel_size = ws
      end
    end
  end
end
