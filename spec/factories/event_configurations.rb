# == Schema Information
#
# Table name: event_configurations
#
#  id                                            :integer          not null, primary key
#  event_url                                     :string
#  start_date                                    :date
#  contact_email                                 :string
#  artistic_closed_date                          :date
#  standard_skill_closed_date                    :date
#  event_sign_up_closed_date                     :date
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  test_mode                                     :boolean          default(FALSE), not null
#  comp_noncomp_url                              :string
#  standard_skill                                :boolean          default(FALSE), not null
#  usa                                           :boolean          default(FALSE), not null
#  iuf                                           :boolean          default(FALSE), not null
#  currency_code                                 :string
#  rulebook_url                                  :string
#  style_name                                    :string
#  custom_waiver_text                            :text
#  music_submission_end_date                     :date
#  artistic_score_elimination_mode_naucc         :boolean          default(FALSE), not null
#  logo_file                                     :string
#  max_award_place                               :integer          default(5)
#  display_confirmed_events                      :boolean          default(FALSE), not null
#  spectators                                    :boolean          default(FALSE), not null
#  paypal_account                                :string
#  waiver                                        :string           default("none")
#  validations_applied                           :integer
#  italian_requirements                          :boolean          default(FALSE), not null
#  rules_file_name                               :string
#  accept_rules                                  :boolean          default(FALSE), not null
#  payment_mode                                  :string           default("disabled")
#  offline_payment                               :boolean          default(FALSE), not null
#  enabled_locales                               :string           not null
#  comp_noncomp_page_id                          :integer
#  under_construction                            :boolean          default(TRUE), not null
#  noncompetitors                                :boolean          default(TRUE), not null
#  volunteer_option                              :string           default("generic"), not null
#  age_calculation_base_date                     :date
#  organization_membership_type                  :string
#  request_address                               :boolean          default(TRUE), not null
#  request_emergency_contact                     :boolean          default(TRUE), not null
#  request_responsible_adult                     :boolean          default(TRUE), not null
#  registrants_should_specify_default_wheel_size :boolean          default(TRUE), not null
#  add_event_end_date                            :datetime
#  max_registrants                               :integer          default(0), not null
#  representation_type                           :string           default("country"), not null
#  waiver_file_name                              :string
#  lodging_end_date                              :datetime
#  time_zone                                     :string           default("Central Time (US & Canada)")
#  stripe_public_key                             :string
#  stripe_secret_key                             :string
#  require_medical_certificate                   :boolean          default(FALSE), not null
#  medical_certificate_info_page_id              :integer
#  volunteer_option_page_id                      :integer
#  add_expenses_end_date                         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :event_configuration do
    short_name { "My conv" }
    long_name { "Some really nice convention" }
    location { "Somewhere" }
    dates_description { "X through Y" }
    event_url { "http://www.naucc.com" }
    start_date { Date.current }
    # logo ""
    currency_code { "USD" }
    contact_email { "robinc@dunlopweb.com" }
    artistic_closed_date { "2013-1-10" }
    waiver { "print" }
    custom_waiver_text { "Online Waiver." }
    usa { false }
    iuf { false }
    event_sign_up_closed_date { Date.current }
    comp_noncomp_url { nil }
    test_mode { true }
    style_name { "base_green_blue" }
    max_award_place { 5 }
    spectators { false }
    paypal_account { "ROBIN+merchant@dunlopweb.com" }
    payment_mode { "enabled" }
    offline_payment { false }
    under_construction { false }

    trait :with_usa do
      usa { true }
      organization_membership_type { "usa" }
    end

    trait :with_waiver_pdf do
      waiver_file_name { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', "sample.pdf"), "application/pdf") }
      waiver { "print" }
    end

    trait :with_custom_rules_pdf do
      rules_file_name { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', "sample.pdf"), "application/pdf") }
      accept_rules { true }
    end
  end
end
