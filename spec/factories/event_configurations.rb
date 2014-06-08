# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  short_name                            :string(255)
#  long_name                             :string(255)
#  location                              :string(255)
#  dates_description                     :string(255)
#  event_url                             :string(255)
#  start_date                            :date
#  logo_binary                           :binary
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  tshirt_closed_date                    :date
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  logo_filename                         :string(255)
#  logo_type                             :string(255)
#  test_mode                             :boolean
#  waiver_url                            :string(255)
#  comp_noncomp_url                      :string(255)
#  has_print_waiver                      :boolean
#  standard_skill                        :boolean          default(FALSE)
#  usa                                   :boolean          default(FALSE)
#  iuf                                   :boolean          default(FALSE)
#  currency_code                         :string(255)
#  currency                              :text
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  has_online_waiver                     :boolean
#  online_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_configuration do
    short_name "My conv"
    long_name "Some really nice convention"
    location "Somewhere"
    dates_description "X through Y"
    event_url "http://www.naucc.com"
    start_date Date.new(2013,1,1)
    #logo ""
    currency nil
    contact_email "robinc@dunlopweb.com"
    artistic_closed_date "2013-1-10"
    standard_skill_closed_date "2013-3-10"
    standard_skill true
    has_print_waiver true
    has_online_waiver false
    online_waiver_text "Online Waiver."
    usa false
    #association :usa_family_expense_item, factory: :expense_item, cost: 100
    #association :usa_individual_expense_item, factory: :expense_item, cost: 50
    iuf false
    tshirt_closed_date "2013-5-10"
    comp_noncomp_url nil
    test_mode true
    style_name "naucc_2013"
  end
end
