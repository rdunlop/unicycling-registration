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

class Registrant < ActiveRecord::Base
  include Eligibility
  include CachedModel

  after_save :touch_members

  has_paper_trail meta: { registrant_id: :id, user_id: :user_id }

  has_one :contact_detail, dependent: :destroy, autosave: true, inverse_of: :registrant
  has_one :standard_skill_routine, dependent: :destroy

  # may move into another object
  has_many :registrant_choices, dependent: :destroy, inverse_of: :registrant
  has_many :registrant_event_sign_ups, dependent: :destroy, inverse_of: :registrant
  has_many :signed_up_events, -> { where ["signed_up = ?", true ] }, class_name: 'RegistrantEventSignUp'
  has_many :registrant_expense_items, -> { includes(expense_item: [expense_group: :translations, translations: []]) }, dependent: :destroy
  has_many :volunteer_choices, dependent: :destroy, inverse_of: :registrant
  has_many :volunteer_opportunities, through: :volunteer_choices

  has_many :payment_details, -> {includes :payment}, dependent: :destroy
  has_many :additional_registrant_accesses, dependent: :destroy
  has_many :registrant_group_members, dependent: :destroy
  has_many :songs, dependent: :destroy

  # THROUGH
  has_many :event_choices, through: :registrant_choices
  has_many :events, through: :event_choices
  has_many :categories, through: :events

  has_many :expense_items, through: :registrant_expense_items

  has_many :payments, through: :payment_details
  has_many :refund_details, through: :payment_details
  has_many :refunds, through: :refund_details

  has_many :registrant_groups, through: :registrant_group_members

  # For event competitions/results
  has_many :members, dependent: :destroy
  has_many :competitors, through: :members
  has_many :competitions, through: :competitors
  has_many :competition_wheel_sizes, dependent: :destroy
  has_many :results, through: :competitors

  belongs_to :default_wheel_size, class_name: "WheelSize", foreign_key: :wheel_size_id
  belongs_to :user

  accepts_nested_attributes_for :contact_detail
  accepts_nested_attributes_for :registrant_choices
  accepts_nested_attributes_for :registrant_event_sign_ups
  accepts_nested_attributes_for :volunteer_choices

  before_create :create_associated_required_expense_items

  # always present validations
  before_validation :set_bib_number, on: :create
  validates :bib_number, presence: true
  validates :registrant_type, inclusion: { in: %w(competitor noncompetitor spectator) }, presence: true
  validates :ineligible, :deleted, inclusion: { in: [true, false] } # because it's a boolean
  validate :no_payments_when_deleted
  before_validation :set_access_code
  validates :access_code, presence: true

  # Wizard status helpers

  # Status progression:
  #  'blank' - No data has been saved
  #  'base_details' - We have entered the base details
  #  'events' - Has entered the events
  #  'contact_details' - Has entered mailing address & signed waiver (if applicable)
  #  'active' - Has entered all data
  def self.statuses
    ["blank", "base_details", "events", "contact_details", "active"]
  end
  validates :status, presence: true
  validates :status, inclusion: { in: statuses }

  # Base details

  # necessary for all registrant types
  before_validation :set_sorted_last_name
  validates :first_name, :last_name, :sorted_last_name, presence: true
  validates :user_id, presence: true

  # necessary for comp/non-comp only (not spectators):
  validates :birthday, :gender, presence: true, if: :comp_noncomp_past_step_1?
  validates :gender, inclusion: {in: %w(Male Female), message: "%{value} must be either 'Male' or 'Female'"}, if: :comp_noncomp_past_step_1?
  validate  :gender_present, if: :comp_noncomp_past_step_1?
  before_validation :set_age, if: :comp_noncomp_past_step_1?
  validates :age, presence: true, if: :comp_noncomp_past_step_1?
  before_validation :set_default_wheel_size, if: :comp_noncomp_past_step_1?
  validates :default_wheel_size, presence: true, if: :comp_noncomp_past_step_1?
  validate :check_default_wheel_size_for_age, if: :comp_noncomp_past_step_1?

  # events
  validate :choices_combination_valid, if: :past_step_2?

  # waiver
  validates :online_waiver_signature, presence: true, if: :needs_waiver?
  validates :rules_accepted, acceptance: { accept: true }, if: :needs_rules_accepted?

  # contact info
  validates_associated :contact_detail, if: :validated?

  # Expense items
  validate :not_exceeding_expense_item_limits
  validates_associated :registrant_expense_items
  validate :has_necessary_free_items, if: :validated?

  scope :active_or_incomplete, -> { where(deleted: false).order(:bib_number) }
  scope :active, -> { where(status: "active").active_or_incomplete }
  scope :started, -> { where.not(status: "blank").active_or_incomplete}

  # is the current status past the desired status
  def status_is_active?(desired_status)
    self.class.statuses.index(status) >= self.class.statuses.index(desired_status)
  end

  # this registrant is on a step subsequent to the initial step
  def past_step_1?
    status_is_active?("base_details")
  end

  # Never true for a spectator
  # Have we entered the base details?
  def comp_noncomp_past_step_1?
    !spectator? && status_is_active?("base_details")
  end

  # Never true for a spectator
  # have we entered events
  def past_step_2?
    !spectator? && status_is_active?("events")
  end

  def needs_waiver?
    EventConfiguration.singleton.has_online_waiver && status_is_active?("contact_details")
  end

  def needs_rules_accepted?
    EventConfiguration.singleton.accept_rules? && status_is_active?("contact_details")
  end

  def spectator?
    registrant_type == 'spectator'
  end

  def validated?
    status == "active"
  end
  # end Wizard

  def set_access_code
    self.access_code ||= SecureRandom.hex(4)
  end

  def to_param
    "#{bib_number}" if persisted?
  end

  def competitor
    registrant_type == 'competitor'
  end

  def self.competitor
    where(registrant_type: 'competitor')
  end

  def self.noncompetitor
    where(registrant_type: 'noncompetitor')
  end

  def self.notcompetitor
    where.not(registrant_type: 'competitor')
  end

  def self.spectator
    where(registrant_type: 'spectator')
  end

  # uses the CachedSetModel feature to give a key for this registrant's competitors
  def members_cache_key
    Member.cache_key_for_set(id)
  end

  def set_sorted_last_name
    self.sorted_last_name = ActiveSupport::Inflector.transliterate(last_name).downcase if last_name
  end

  # updates the members, which update the competitors, if this competitor has changed (like their age, for example)
  def touch_members
    members.each do |mem|
      mem.touch
    end
  end

  def self.select_box_options
    active.competitor.map{ |reg| [reg.with_id_to_s, reg.id] }
  end

  def self.all_select_box_options
    started.map{ |reg| [reg.with_id_to_s, reg.id] }
  end

  def build_registration_item(reg_item)
    unless reg_item.nil? || has_expense_item?(reg_item)
      registrant_expense_items.build(expense_item: reg_item, system_managed: true)
    end
  end

  def matching_competition_in_event(event)
    competitors.find{ |competitor| competitor.event == event }.try(:competition)
  end

  def create_associated_required_expense_items
    RequiredExpenseItemCreator.new(self).create
  end

  # determine if this registrant has an unpaid (or paid) version of this expense item
  def has_expense_item?(expense_item)
    all_expense_items.include?(expense_item)
  end

  def registration_item
    all_reg_items = RegistrationPeriod.all_registration_expense_items
    registrant_expense_items.where({system_managed: true, expense_item_id: all_reg_items}).first
  end

  # for use when overriding the default system-managed reg_item
  def set_registration_item_expense(expense_item, lock = true)
    return true if reg_paid?
    curr_rei = registration_item

    if curr_rei.nil?
      curr_rei = build_registration_item(expense_item)
    end
    return false if curr_rei.nil?
    return true  if curr_rei.expense_item == expense_item
    return true  if curr_rei.locked

    curr_rei.expense_item = expense_item
    curr_rei.locked = lock
    curr_rei.save
  end

  def self.maximum_bib_number(is_competitor)
    if is_competitor
      competitor.maximum("bib_number")
    else
      notcompetitor.maximum('bib_number')
    end
  end

  def set_bib_number
    if bib_number.nil?
      prev_value = Registrant.maximum_bib_number(competitor)

      if competitor
        initial_value = 1
      else
        initial_value = 2001
      end

      if prev_value.nil?
        self.bib_number = initial_value
      else
        self.bib_number = prev_value + 1
      end
    end
  end

  def wheel_size_id_for_event(event)
    competition_wheel_sizes.select{ |cws| cws.event_id == event.id }.try(:wheel_size_id) || wheel_size_id
  end

  def set_default_wheel_size
    if default_wheel_size.nil?
      if age > 10
        self.default_wheel_size = WheelSize.find_by_description("24\" Wheel")
      else
        self.default_wheel_size = WheelSize.find_by_description("20\" Wheel")
      end
    end
  end

  def check_default_wheel_size_for_age
    if age > 10
      if default_wheel_size && default_wheel_size.description != "24\" Wheel"
        errors[:base] << "You must choose a wheel size of 24\" if you are > 10 years old"
      end
    end
  end

  def external_id
    bib_number
  end

  def gender_present
    if gender.blank?
      errors[:gender_male] = "" # Cause the label to be highlighted
      errors[:gender_female] = "" # Cause the label to be highlighted
    end
  end

  def no_payments_when_deleted
    if paid_details.count > 0 && deleted?
      errors[:base] << "Cannot delete a registration which has completed payments (refund them before deleting the registrant)"
    end
  end

  # ####################################
  # Event Choices Validation
  # ####################################
  def choices_combination_valid
    ChoicesValidator.new(self).validate
  end

  def minor?
    age < 18
  end

  # for displaying on the Registrant#Summary page
  # if this user is signed up for an event category which is now "warning" flagged
  def event_warnings
    warned_sign_ups = signed_up_events.joins(:event_category).includes(:event, :event_category).merge(EventCategory.with_warnings)
    warned_sign_ups.map{|rei| "#{rei.event} - #{rei.event_category.name} Category" }
  end

  def age_at_event_date(event_date)
    if (birthday.month < event_date.month) || (birthday.month == event_date.month && birthday.day <= event_date.day)
      event_date.year - birthday.year
    else
      (event_date.year - 1) - birthday.year
    end
  end

  def set_age
    start_date = EventConfiguration.singleton.start_date
    if start_date.nil? || birthday.nil?
      self.age = 99
    else
      self.age = age_at_event_date(start_date)
    end
  end

  def has_standard_skill?
    signed_up_events.includes(event_category: [:event]).each do |rc|
      next if rc.event_category.nil?
      if rc.event_category.event.standard_skill?
        return true
      end
    end
    false
  end

  def name
    printed_name = full_name
    printed_name += " (incomplete)" unless self.validated?
    display_eligibility(printed_name, ineligible)
  end

  def full_name
    first_name + " " + last_name
  end

  def email
    contact_detail.try(:email).try(:presence) || user.email
  end

  delegate :country_code, :country, :state, :club, to: :contact_detail, allow_nil: true

  def to_s
    name + (deleted ? " (deleted)" : "")
  end

  def with_id_to_s
    "##{bib_number} - #{self}"
  end

  ###### Expenses ##########

  # Indicates that this registrant has paid their registration_fee
  def reg_paid?
    return true if spectator?
    Rails.cache.fetch("/registrant/#{id}-#{updated_at}/reg_paid") do
      RegistrationPeriod.paid_for_period(competitor, paid_expense_items).present?
    end
  end

  # return a list of _ALL_ of the expense_items for this registrant
  #  PAID FOR or NOT
  def all_expense_items
    owing_expense_items + paid_expense_items
  end

  def amount_owing
    Rails.cache.fetch("/registrants/#{id}-#{updated_at}/amount_owing") do
      registrant_expense_items.inject(0){|total, item| total + item.total_cost}
    end
  end

  def expenses_total
    amount_owing + amount_paid
  end

  # returns a list of expense_items that this registrant hasn't paid for
  # INCLUDING the registration cost
  def owing_expense_items
    registrant_expense_items.map{|eid| eid.expense_item}
  end

  # pass back the details too, so that we don't mis-associate them when building the payment
  def owing_expense_items_with_details
    registrant_expense_items.map{|rei| [rei.expense_item, rei.details]}
  end

  def owing_registrant_expense_items
    registrant_expense_items
  end

  # returns a list of paid-for expense_items
  def paid_expense_items
    paid_details.map{|pd| pd.expense_item }
  end

  def paid_details
    payment_details.completed.clone
  end

  def amount_paid
    Rails.cache.fetch("/registrants/#{id}-#{updated_at}/amount_paid") do
      paid_details.inject(0){|total, item| total + item.cost}
    end
  end

  ############# Events Selection ########
  def has_event_in_category?(category)
    category.events.any?{|event| has_event?(event) }
  end

  def has_confirmed_event_in_category?(category)
    category.events.any?{|event| has_confirmed_event?(event) }
  end

  def has_unconfirmed_event_in_category?(category)
    category.events.any?{|event| has_unconfirmed_event?(event) }
  end

  # does this registrant have this event checked off?
  def has_event?(event)
    @has_event ||= {}
    @has_event[event] ||= signed_up_events.where({event_id: event.id}).any?
  end

  def active_competitors(event)
    competitors.includes(competition: :event).active.joins(:competition).where("competitions.event_id = ?", event)
  end

  def active_competitor(event)
    active_competitors(event).first
  end

  def has_confirmed_event?(event)
    @has_confirmed_event ||= {}
    @has_confirmed_event[event] ||= (active_competitors(event).count > 0)
  end

  def has_unconfirmed_event?(event)
    @has_unconfirmed_event ||= {}
    @has_unconfirmed_event[event] ||= has_event?(event) && !has_confirmed_event?(event)
  end

  def describe_event(event)
    details = describe_event_hash(event)
    description = details[:description]

    unless details[:category].nil?
      description += " - Category: " + details[:category]
    end

    unless details[:additional].nil?
      description += " - " + details[:additional]
    end
    description
  end

  def describe_event_hash(event)
    results = {}
    results[:description] = event.name

    resu = signed_up_events.where({event_id: event.id}).first
    # only add the Category if there are more than 1
    results[:category] = nil
    if event.event_categories.size > 1
      results[:category] = resu.event_category.name.to_s unless resu.nil?
    end

    results[:additional] = nil
    event.event_choices.each do |ec|
      my_val = registrant_choices.where({event_choice_id: ec.id}).first
      unless my_val.nil? || !my_val.has_value?
        results[:additional] += " - " unless results[:additional].nil?
        results[:additional] = "" if results[:additional].nil?
        results[:additional] += ec.label + ": " + my_val.describe_value
      end
    end

    results
  end

  # return true/false to show whether an expense_group has been chosen by this registrant
  def has_chosen_free_item_from_expense_group(expense_group)
    registrant_expense_items.each do |rei|
      next unless rei.free
      if rei.expense_item.expense_group == expense_group
        return true
      end
    end
    paid_details.each do |pei|
      next unless pei.free
      if pei.expense_item.expense_group == expense_group
        return true
      end
    end

    false
  end

  def has_chosen_free_item_of_expense_item(expense_item)
    registrant_expense_items.each do |rei|
      next unless rei.free
      if rei.expense_item == expense_item
        return true
      end
    end
    paid_details.each do |pei|
      next unless pei.free
      if pei.expense_item == expense_item
        return true
      end
    end

    false
  end

  def expense_item_is_free(expense_item)
    free_options = nil
    if competitor
      free_options = expense_item.expense_group.competitor_free_options
    else
      free_options = expense_item.expense_group.noncompetitor_free_options
    end
    case free_options
    when "One Free In Group", "One Free In Group REQUIRED"
      return !has_chosen_free_item_from_expense_group(expense_item.expense_group)
    when "One Free of Each In Group"
      return !has_chosen_free_item_of_expense_item(expense_item)
    else
      return false
    end
  end

  def not_exceeding_expense_item_limits
    expense_items = registrant_expense_items.map{|rei| rei.new_record? ? rei.expense_item : nil}.reject { |ei| ei.nil? }
    expense_items.uniq.each do |ei|
      num_ei = expense_items.count(ei)
      if !ei.can_i_add?(num_ei)
        errors[:base] << "There are not that many #{ei} available"
      end
    end
  end

  def has_necessary_free_items
    if competitor
      free_groups_required = ExpenseGroup.where(competitor_free_options: "One Free In Group REQUIRED")
    else
      free_groups_required = ExpenseGroup.where(noncompetitor_free_options: "One Free In Group REQUIRED")
    end
    free_groups_required.each do |expense_group|
      if all_expense_items.none? { |expense_item| expense_item.expense_group == expense_group}
        errors[:base] << "You must choose a free #{expense_group}"
      end
    end
  end

  def paid_individual_usa?
    ind = EventConfiguration.singleton.usa_individual_expense_item
    paid_expense_items.include?(ind)
  end

  def paid_family_usa?
    fam = EventConfiguration.singleton.usa_family_expense_item
    paid_expense_items.include?(fam)
  end

  def usa_membership_paid?
    contact_detail.usa_confirmed_paid || contact_detail.usa_family_membership_holder_id? || paid_individual_usa?|| paid_family_usa?
  end

  def usa_family_membership_details
    paid_details.select{|pd| pd.expense_item == EventConfiguration.singleton.usa_family_expense_item}.try(:details)
  end
end
