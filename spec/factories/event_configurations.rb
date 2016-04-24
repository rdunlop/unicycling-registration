# == Schema Information
#
# Table name: event_configurations
#
#  id                                            :integer          not null, primary key
#  event_url                                     :string(255)
#  start_date                                    :date
#  contact_email                                 :string(255)
#  artistic_closed_date                          :date
#  standard_skill_closed_date                    :date
#  event_sign_up_closed_date                     :date
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  test_mode                                     :boolean          default(FALSE), not null
#  comp_noncomp_url                              :string(255)
#  standard_skill                                :boolean          default(FALSE), not null
#  usa                                           :boolean          default(FALSE), not null
#  iuf                                           :boolean          default(FALSE), not null
#  currency_code                                 :string(255)
#  rulebook_url                                  :string(255)
#  style_name                                    :string(255)
#  custom_waiver_text                            :text
#  music_submission_end_date                     :date
#  artistic_score_elimination_mode_naucc         :boolean          default(TRUE), not null
#  logo_file                                     :string(255)
#  max_award_place                               :integer          default(5)
#  display_confirmed_events                      :boolean          default(FALSE), not null
#  spectators                                    :boolean          default(FALSE), not null
#  paypal_account                                :string(255)
#  waiver                                        :string(255)      default("none")
#  validations_applied                           :integer
#  italian_requirements                          :boolean          default(FALSE), not null
#  rules_file_name                               :string(255)
#  accept_rules                                  :boolean          default(FALSE), not null
#  paypal_mode                                   :string(255)      default("disabled")
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
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_configuration do
    short_name "My conv"
    long_name "Some really nice convention"
    location "Somewhere"
    dates_description "X through Y"
    event_url "http://www.naucc.com"
    start_date Date.new(2013, 1, 1)
    # logo ""
    currency_code "USD"
    contact_email "robinc@dunlopweb.com"
    artistic_closed_date "2013-1-10"
    waiver "print"
    custom_waiver_text "Online Waiver."
    usa false
    iuf false
    event_sign_up_closed_date "2013-5-10"
    comp_noncomp_url nil
    test_mode true
    style_name "base_green_blue"
    max_award_place 5
    spectators false
    paypal_account "ROBIN+merchant@dunlopweb.com"
    paypal_mode "enabled"
    offline_payment false
    under_construction false

    trait :with_usa do
      usa true
      organization_membership_type "usa"
    end
  end
end
