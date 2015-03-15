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
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean
#  comp_noncomp_url                      :string(255)
#  standard_skill                        :boolean          default(FALSE)
#  usa                                   :boolean          default(FALSE)
#  iuf                                   :boolean          default(FALSE)
#  currency_code                         :string(255)
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  custom_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE)
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE)
#  spectators                            :boolean          default(FALSE)
#  usa_membership_config                 :boolean          default(FALSE)
#  paypal_account                        :string(255)
#  paypal_test                           :boolean          default(TRUE), not null
#  waiver                                :string(255)      default("none")
#  validations_applied                   :integer
#  italian_requirements                  :boolean          default(FALSE), not null
#

class EventConfiguration < ActiveRecord::Base
  include MultiLevelValidation
  specify_validations :base_settings, :name_logo, :payment_settings, :important_dates

  translates :short_name, :long_name, :location, :dates_description
  translates :competitor_benefits, :noncompetitor_benefits, :spectator_benefits
  accepts_nested_attributes_for :translations

  mount_uploader :logo_file, LogoUploader

  # Need to make these validations only apply when certain forms are submitted?
  validates :short_name, :long_name, :presence => true, if: :name_logo_applied?
  validates :event_url, :format => URI.regexp(%w(http https)), :unless => "event_url.nil?"
  validates :comp_noncomp_url, :format => URI.regexp(%w(http https)), :unless => "comp_noncomp_url.nil? or comp_noncomp_url.empty?"

  def self.style_names
    [["Blue and Pink", "unicon_17"], ["Green and Blue", "naucc_2013"], ["Blue Purple Green", "naucc_2014"], ["Purple Blue Green", "naucc_2015"]]
  end

  def self.currency_codes
    ["USD", "CAD", "EUR"]
  end

  validates :currency_code, inclusion: { in: self.currency_codes }, allow_nil: true
  # base settings
  validates :style_name, :inclusion => {:in => self.style_names.map{|y| y[1]} }, if: :base_settings_applied?
  validates :waiver, inclusion: { in: ["none", "online", "print"] }, if: :base_settings_applied?
  validates :usa_membership_config, :standard_skill, :inclusion => { :in => [true, false] }, if: :base_settings_applied? # because it's a boolean
  validates :artistic_score_elimination_mode_naucc, :inclusion => { :in => [true, false] }, if: :base_settings_applied? # because it's a boolean
  validates :standard_skill_closed_date, :presence => true, :unless => "standard_skill.nil? or standard_skill == false"

  belongs_to :usa_individual_expense_item, :class_name => "ExpenseItem"
  belongs_to :usa_family_expense_item, :class_name => "ExpenseItem"

  validates :usa_individual_expense_item, :usa_family_expense_item, presence: { message: "Must be specified when enabling 'usa' mode"}, if: "self.usa_membership_config"

  validates :usa, :iuf, :inclusion => { :in => [true, false] }, if: :important_dates_applied? # because it's a boolean
  validates :test_mode, :inclusion => { :in => [true, false] }, if: :important_dates_applied? # because it's a boolean
  validates :max_award_place, presence: true, if: :important_dates_applied?

  before_validation :clear_of_blank_strings

  after_initialize :init

  def init
    self.test_mode = true if self.test_mode.nil?
    self.usa = true if self.usa.nil?
    self.usa_membership_config = false if self.usa_membership_config.nil?
    self.iuf = false if self.iuf.nil?
    self.standard_skill = true if self.standard_skill.nil?
    self.artistic_score_elimination_mode_naucc = true if self.artistic_score_elimination_mode_naucc.nil?
    self.style_name ||= "naucc_2013"
    self.long_name ||= ""
    self.short_name ||= ""
    self.currency_code ||= "USD"
    self.contact_email ||= ""
    self.max_award_place ||= 5
    self.display_confirmed_events = false if self.display_confirmed_events.nil?
  end

  def currency
    case currency_code
    when "USD"
      "%u%n USD"
    when "CAD"
      "%u%n CAD"
    when "EUR"
      "%n%u"
    end
  end

  def currency_unit
    case currency_code
    when "USD"
      "$"
    when "CAD"
      "$"
    when "EUR"
      "€"
    end
  end

  def has_print_waiver
    waiver == "print"
  end

  def has_online_waiver
    waiver == "online"
  end

  def self.default_waiver_text
    I18n.t("waiver_text")
  end

  def waiver_text
    return custom_waiver_text unless custom_waiver_text.blank?
    self.class.default_waiver_text
  end

  def benefits_list(text)
    if text
      text.split("\n")
    else
      []
    end
  end

  def competitor_benefits_list
    benefits_list(competitor_benefits)
  end

  def noncompetitor_benefits_list
    benefits_list(noncompetitor_benefits)
  end

  def spectator_benefits_list
    benefits_list(spectator_benefits)
  end

  # allows creating competitors during lane assignment
  # (only at NAUCC)
  def can_create_competitors_at_lane_assignment
    usa
  end

  def clear_of_blank_strings
    self.rulebook_url = nil if rulebook_url.blank?
    self.event_url = nil if event_url.blank?
  end

  def self.singleton
    EventConfiguration.includes(:translations).first || EventConfiguration.new
  end

  def self.paypal_base_url
    paypal_test_url = "https://www.sandbox.paypal.com"
    paypal_live_url = "https://www.paypal.com"

    if singleton.paypal_test?
      paypal_test_url
    else
      paypal_live_url
    end
  end

  def self.closed?(today = Date.today)
    last_online_rp = RegistrationPeriod.last_online_period

    if last_online_rp.nil?
      false
    else
      last_online_rp.last_day < today
    end
  end

  def standard_skill_closed?(today = Date.today)
    return false if standard_skill_closed_date.nil?
    standard_skill_closed_date <= today
  end

  def artistic_closed?(today = Date.today)
    return false if artistic_closed_date.nil?
    artistic_closed_date < today
  end

  def event_sign_up_closed?(today = Date.today)
    return false if event_sign_up_closed_date.nil?
    event_sign_up_closed_date < today
  end

  def music_submission_ended?(today = Date.today)
    return true if music_submission_end_date.nil?
    music_submission_end_date <= today
  end

  def self.configuration_exists?
    !EventConfiguration.first.nil?
  end

  def self.reset_counter_caches
    Event.all.each do |event|
      Event.reset_counters(event.id, :event_categories)
      Event.reset_counters(event.id, :event_choices)
    end
  end
end
