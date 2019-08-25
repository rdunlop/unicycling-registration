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
#

class EventConfiguration < ApplicationRecord
  include MultiLevelValidation

  specify_validations :base_settings, :name_logo, :payment_settings, :important_dates

  translates :short_name, :long_name, :location, :dates_description, fallbacks_for_empty_translations: true
  translates :competitor_benefits, :noncompetitor_benefits, :spectator_benefits, fallbacks_for_empty_translations: true
  translates :offline_payment_description, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  mount_uploader :logo_file, LogoUploader

  validates :short_name, :long_name, presence: true, if: :name_logo_applied?
  validates :event_url, format: URI.regexp(%w[http https]), unless: -> { event_url.nil? }
  validates :comp_noncomp_url, format: URI.regexp(%w[http https]), unless: -> { comp_noncomp_url.blank? }
  validates :enabled_locales, presence: true
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.send(:zones_map).keys }
  validate :only_one_info_type
  validate :stripe_or_paypal_only

  def self.style_names
    [["Blue and Pink", "base_blue_pink"], ["Green and Blue", "base_green_blue"], ["Blue Purple Green", "base_blue_purple"], ["Purple Blue Green", "base_purple_blue"]]
  end

  def self.currency_codes
    ["USD", "CAD", "EUR", "DKK"]
  end

  VOLUNTEER_OPTIONS = [
    "none",
    "generic",
    "choice",
    "info_page"
  ].freeze

  validates :currency_code, inclusion: { in: currency_codes }, allow_nil: true
  validates :style_name, inclusion: { in: style_names.map { |y| y[1] } }
  validates :waiver, inclusion: { in: ["none", "online", "print"] }

  mount_uploader :waiver_file_name, PdfUploader

  validates :volunteer_option, inclusion: { in: VOLUNTEER_OPTIONS }
  validates :volunteer_option_page_id, presence: true, if: -> { volunteer_option == "info_page" }
  validates :volunteer_option_page_id, absence: true, unless: -> { volunteer_option == "info_page" }
  belongs_to :volunteer_option_page, class_name: "Page"

  belongs_to :medical_certificate_info_page, class_name: "Page"

  validates :representation_type, inclusion: { in: RepresentationType::TYPES }

  validates :standard_skill, inclusion: { in: [true, false] }
  validates :standard_skill_closed_date, presence: true, unless: -> { standard_skill.nil? || (standard_skill == false) }

  validates :usa, :iuf, inclusion: { in: [true, false] }
  validates :test_mode, inclusion: { in: [true, false] }

  validates_date :artistic_closed_date, on_or_before: :event_sign_up_closed_date, allow_nil: true, if: -> { event_sign_up_closed_date.present? }

  validates :artistic_score_elimination_mode_naucc, inclusion: { in: [true, false] }
  validates :max_award_place, presence: true
  validates :max_registrants, presence: true
  validates :max_registrants, numericality: { greater_than_or_equal_to: 0 }

  def self.organization_membership_types
    ["usa", "french_federation", "iuf"]
  end

  validates :organization_membership_type, inclusion: { in: organization_membership_types }, allow_blank: true

  def organization_membership_config?
    organization_membership_type.present?
  end

  def self.payment_modes
    ["disabled", "test", "enabled"]
  end

  validates :payment_mode, inclusion: { in: payment_modes }

  nilify_blanks only: %i[rulebook_url event_url], before: :validation

  mount_uploader :rules_file_name, PdfUploader

  belongs_to :comp_noncomp_page, class_name: "Page"

  after_initialize :init

  def init
    self.style_name ||= "base_green_blue"
    self.currency_code ||= "USD"
    self.max_award_place ||= 5
    # Cannot use `self.enabled_locales` because that conflicts with a method name
    self[:enabled_locales] ||= ["en", "fr", "de", "es", "da"].join(",")
  end

  def additional_info?
    comp_noncomp_page_id.present? || comp_noncomp_page.present?
  end

  def currency
    case currency_code
    when "USD"
      "%u%n USD"
    when "CAD"
      "%u%n CAD"
    when "EUR"
      "%n%u"
    when "DKK"
      "%n %u"
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
    when "DKK"
      "Kr."
    end
  end

  def online_payment?
    payment_mode == "test" || payment_mode == "enabled"
  end

  def can_only_drop_or_modify_events?
    return false if add_event_end_date.blank?

    is_date_in_the_past?(add_event_end_date)
  end

  def paypal_test?
    payment_mode == "test"
  end

  def print_waiver?
    return false if waiver_file_name.blank?

    waiver == "print"
  end

  def online_waiver?
    waiver == "online"
  end

  def self.default_waiver_text
    I18n.t("waiver_text")
  end

  def waiver_text
    return custom_waiver_text if custom_waiver_text.present?

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
  def can_create_competitors_at_lane_assignment?
    usa?
  end

  # Display State instead of Country
  def state?
    usa?
  end

  def volunteer?
    volunteer_option != "none"
  end

  def self.singleton
    # Use the request-level EventConfiguration, if it is defined, otherwise, fall-back
    # to fetching from the DB
    return @config if defined?(@config)

    if RequestStore.store[:ec_tenant] != Apartment::Tenant.current
      # Prevent EventConfiguration.singleton to be shared across tenants
      RequestStore.clear!
      RequestStore.store[:ec_tenant] = Apartment::Tenant.current
    end
    RequestStore.store[:ec_singleton] ||= EventConfiguration.includes(:translations).first || EventConfiguration.new
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

  def self.under_construction?
    singleton.under_construction?
  end

  def registration_closed_date
    reg_cost_closed_date = RegistrationCost.for_type("competitor").last_online_period.try(:end_date).try(:+, 1.day)
    reg_cost_closed_date || event_sign_up_closed_date.try(:+, 1.day)
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

  def effective_lodging_closed_date
    lodging_end_date || registration_closed_date
  end

  # Public: What is the base date we should use when calculating competitor
  # Ages.
  # Default to the start date of the competition, but can be changed, if
  # necessary
  def effective_age_calculation_base_date
    age_calculation_base_date || start_date
  end

  def registration_closed?
    return true if under_construction?

    # allow 1 day of grace to registration_closed_date
    is_date_in_the_past?(registration_closed_date)
  end

  def new_registration_closed?
    return true if registration_closed?
    return false if max_registrants.zero?

    Registrant.not_deleted.count >= max_registrants
  end

  def standard_skill_closed?
    is_date_in_the_past?(effective_standard_skill_closed_date)
  end

  def artistic_closed?
    is_date_in_the_past?(effective_artistic_closed_date)
  end

  def music_submission_ended?
    is_date_in_the_past?(effective_music_submission_end_date)
  end

  def event_sign_up_closed?
    is_date_in_the_past?(effective_event_sign_up_closed_date)
  end

  def lodging_sales_closed?
    is_date_in_the_past?(effective_lodging_closed_date)
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
    languages = values.reject { |x| x.blank? }
    # add default, since it's the configured fallback it must exist
    languages = (languages << I18n.default_locale.to_s).uniq
    self[:enabled_locales] = languages.join(",")
  end

  def self.all_available_languages
    %i[en fr de es it da]
  end

  # Public: What is the maximum age that we should allow users to configure
  # their wheel size?
  def wheel_size_configuration_max_age
    10
  end

  # Public: Is the USA-style membership system enabled?
  def organization_membership_usa?
    organization_membership_type == "usa"
  end

  def organization_membership_config
    case organization_membership_type
    when "usa"
      Organization::Usa.new
    when "french_federation"
      Organization::FrenchFederation.new
    when "iuf"
      Organization::Iuf.new
    else
      Organization::None.new
    end
  end

  def has_lodging?
    return @has_lodging if defined?(@has_lodging)

    @has_lodging = LodgingDay.any?
  end

  def has_expenses?
    return @has_expenses if defined?(@has_expenses)

    @has_expenses = ExpenseItem.any_in_use?
  end

  def payment_account?
    paypal_account? || stripe_secret_key?
  end

  private

  def is_date_in_the_past?(date)
    return false if date.nil?

    date < Date.current
  end

  def benefits_list(text)
    if text
      text.split("\n")
    else
      []
    end
  end

  def only_one_info_type
    if comp_noncomp_url.present? && comp_noncomp_page.present?
      errors.add(:comp_noncomp_page_id, "Unable to specify both Comp-NonComp URL and Comp-NonComp Page")
    end
  end

  def stripe_or_paypal_only
    if paypal_account.present? && stripe_secret_key.present?
      errors.add(:paypal_account, "Cannot specify BOTH stripe AND paypal")
    end
  end
end
