# == Schema Information
#
# Table name: registrants
#
#  id                       :integer          not null, primary key
#  first_name               :string
#  middle_initial           :string
#  last_name                :string
#  birthday                 :date
#  gender                   :string
#  created_at               :datetime
#  updated_at               :datetime
#  user_id                  :integer
#  deleted                  :boolean          default(FALSE), not null
#  bib_number               :integer          not null
#  wheel_size_id            :integer
#  age                      :integer
#  ineligible               :boolean          default(FALSE), not null
#  volunteer                :boolean          default(FALSE), not null
#  online_waiver_signature  :string
#  access_code              :string
#  sorted_last_name         :string
#  status                   :string           default("active"), not null
#  registrant_type          :string           default("competitor")
#  rules_accepted           :boolean          default(FALSE), not null
#  online_waiver_acceptance :boolean          default(FALSE), not null
#  medical_document_url     :string
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_bib_number       (bib_number) UNIQUE
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :registrant do
    sequence(:first_name) { |n| "FirstMyString #{n}" }
    middle_initial { "MMyString" }
    last_name { "LastMyString" }
    birthday { 18.years.ago }
    gender { "Male" }
    user # FactoryBot
    registrant_type { 'competitor' }
    ineligible { false }
    contact_detail # FactoryBot

    # New Way
    trait :competitor do
      registrant_type { 'competitor' }
    end
    trait :noncompetitor do
      registrant_type { 'noncompetitor' }
    end
    trait :spectator do
      registrant_type { 'spectator' }
    end

    trait :minor do
      before(:create) do |reg|
        reg.contact_detail.responsible_adult_name = "Bob Smith"
        reg.contact_detail.responsible_adult_phone = "911"
      end
    end

    # old way
    factory :competitor do
      registrant_type { 'competitor' }
    end
    factory :noncompetitor do
      registrant_type { 'noncompetitor' }
    end
    factory :spectator do
      registrant_type { 'spectator' }
    end
    # end Old-way

    before(:create) do
      if WheelSize.count == 0
        @ws20 = FactoryBot.create(:wheel_size_20)
        @ws24 = FactoryBot.create(:wheel_size_24)
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
