# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  event_url                             :string(255)
#  start_date                            :date
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean          default(FALSE), not null
#  comp_noncomp_url                      :string(255)
#  standard_skill                        :boolean          default(FALSE), not null
#  usa                                   :boolean          default(FALSE), not null
#  iuf                                   :boolean          default(FALSE), not null
#  currency_code                         :string(255)
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  custom_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE), not null
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE), not null
#  spectators                            :boolean          default(FALSE), not null
#  usa_membership_config                 :boolean          default(FALSE), not null
#  paypal_account                        :string(255)
#  waiver                                :string           default("none")
#  validations_applied                   :integer
#  italian_requirements                  :boolean          default(FALSE), not null
#  rules_file_name                       :string
#  accept_rules                          :boolean          default(FALSE), not null
#  paypal_mode                           :string           default("disabled")
#  offline_payment                       :boolean          default(FALSE), not null
#  enabled_locales                       :string           default("en,fr"), not null
#

class EventConfiguration < ActiveRecord::Base
  include MultiLevelValidation
  specify_validations :base_settings, :name_logo, :payment_settings, :important_dates

  translates :short_name, :long_name, :location, :dates_description, fallbacks_for_empty_translations: true
  translates :competitor_benefits, :noncompetitor_benefits, :spectator_benefits, fallbacks_for_empty_translations: true
  translates :offline_payment_description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  mount_uploader :logo_file, LogoUploader

  validates :short_name, :long_name, presence: true, if: :name_logo_applied?
  validates :event_url, format: URI.regexp(%w(http https)), unless: "event_url.nil?"
  validates :comp_noncomp_url, format: URI.regexp(%w(http https)), unless: "comp_noncomp_url.nil? or comp_noncomp_url.empty?"
  validates :enabled_locales, presence: true

  def self.style_names
    [["Blue and Pink", "unicon_17"], ["Green and Blue", "naucc_2013"], ["Blue Purple Green", "naucc_2014"], ["Purple Blue Green", "naucc_2015"]]
  end

  def self.currency_codes
    ["USD", "CAD", "EUR"]
  end

  validates :currency_code, inclusion: { in: currency_codes }, allow_nil: true
  validates :style_name, inclusion: {in: style_names.map{|y| y[1]} }
  validates :waiver, inclusion: { in: ["none", "online", "print"] }

  validates :usa_membership_config, :standard_skill, inclusion: { in: [true, false] }
  validates :standard_skill_closed_date, presence: true, unless: "standard_skill.nil? or standard_skill == false"

  belongs_to :usa_individual_expense_item, class_name: "ExpenseItem"
  belongs_to :usa_family_expense_item, class_name: "ExpenseItem"

  validates :usa, :iuf, inclusion: { in: [true, false] }
  validates :test_mode, inclusion: { in: [true, false] }

  validates :artistic_score_elimination_mode_naucc, inclusion: { in: [true, false] }
  validates :max_award_place, presence: true

  def self.paypal_modes
    ["disabled", "test", "enabled"]
  end

  validates :paypal_mode, inclusion: { in: paypal_modes }

  before_validation :clear_of_blank_strings

  mount_uploader :rules_file_name, PdfUploader

  after_initialize :init

  def init
    self.style_name ||= "naucc_2013"
    self.currency_code ||= "USD"
    self.max_award_place ||= 5
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

  def online_payment?
    paypal_mode == "test" || paypal_mode == "enabled"
  end

  def paypal_test?
    paypal_mode == "test"
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
    usa?
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

  def self.closed?
    singleton.registration_closed?
  end

  def registration_closed_date
    RegistrationPeriod.last_online_period.try(:end_date).try(:+, 1.day)
  end

  def effective_standard_skill_closed_date
    standard_skill_closed_date || registration_closed_date
  end

  def effective_artistic_closed_date
    artistic_closed_date || registration_closed_date
  end

  def effective_music_submission_end_date
    music_submission_end_date || registration_closed_date
  end

  def effective_event_sign_up_closed_date
    event_sign_up_closed_date || registration_closed_date
  end

  def registration_closed?
    # allow 1 day of grace to registration_closed_date
    is_date_in_the_past?(registration_closed_date)
  end

  def standard_skill_closed?
    is_date_in_the_past?(effective_standard_skill_closed_date)
  end

  def artistic_closed?
    is_date_in_the_past?(effective_artistic_closed_date)
  end

  def music_submission_ended?
    is_date_in_the_past?(music_submission_end_date)
  end

  def event_sign_up_closed?
    is_date_in_the_past?(effective_event_sign_up_closed_date)
  end

  def self.configuration_exists?
    !EventConfiguration.first.nil?
  end

  def self.reset_counter_caches
    Event.all.find_each do |event|
      Event.reset_counters(event.id, :event_categories)
      Event.reset_counters(event.id, :event_choices)
    end
  end

  # Convert from stored string "en,fr" to [:en, :fr]
  def enabled_locales
    self[:enabled_locales].split(",").map(&:to_sym)
  end

  # convert from passed in array ["", "en", "fr"] to "en,fr"
  def enabled_locales=(values)
    languages = values.reject{|x| x.blank?}
    # add default, since it's the configured fallback it must exist
    languages = (languages << I18n.default_locale.to_s).uniq
    self[:enabled_locales] = languages.join(",")
  end

  def self.all_available_languages
    [:en, :fr, :de, :hu]
  end

  private

  def is_date_in_the_past?(date)
    return false if date.nil?
    date < Date.today
  end

  def clear_of_blank_strings
    self.rulebook_url = nil if rulebook_url.blank?
    self.event_url = nil if event_url.blank?
  end

  def benefits_list(text)
    if text
      text.split("\n")
    else
      []
    end
  end
end
