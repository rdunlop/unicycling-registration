# == Schema Information
#
# Table name: registrants
#
#  id                       :integer          not null, primary key
#  first_name               :string(255)
#  middle_initial           :string(255)
#  last_name                :string(255)
#  birthday                 :date
#  gender                   :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  user_id                  :integer
#  deleted                  :boolean          default(FALSE), not null
#  bib_number               :integer          not null
#  wheel_size_id            :integer
#  age                      :integer
#  ineligible               :boolean          default(FALSE), not null
#  volunteer                :boolean          default(FALSE), not null
#  online_waiver_signature  :string(255)
#  access_code              :string(255)
#  sorted_last_name         :string(255)
#  status                   :string(255)      default("active"), not null
#  registrant_type          :string(255)      default("competitor")
#  rules_accepted           :boolean          default(FALSE), not null
#  online_waiver_acceptance :boolean          default(FALSE), not null
#  paid                     :boolean          default(FALSE), not null
#
# Indexes
#
#  index_registrants_deleted             (deleted)
#  index_registrants_on_bib_number       (bib_number) UNIQUE
#  index_registrants_on_registrant_type  (registrant_type)
#  index_registrants_on_user_id          (user_id)
#

class Registrant < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include Eligibility
  include Representable
  include CachedModel
  extend OrderAsSpecified

  after_save :touch_members
  after_save :update_usa_membership_status, if: proc { EventConfiguration.singleton.organization_membership_usa? }

  has_paper_trail meta: { registrant_id: :id, user_id: :user_id }

  with_options dependent: :destroy do
    has_one :contact_detail, autosave: true, inverse_of: :registrant
    has_one :standard_skill_routine
  end

  # may move into another object
  with_options dependent: :destroy do
    has_many :registrant_best_times, inverse_of: :registrant
    has_many :registrant_choices, inverse_of: :registrant
    has_many :registrant_event_sign_ups, inverse_of: :registrant
    has_many :registrant_expense_items, -> { includes(expense_item: [expense_group: :translations, translations: []]) }, autosave: true
    has_many :payment_details, -> {includes :payment}, inverse_of: :registrant
    has_many :additional_registrant_accesses
    has_many :registrant_group_members
    has_many :songs
    has_many :volunteer_choices, inverse_of: :registrant
  end

  has_many :signed_up_events, -> { where(signed_up: true) }, class_name: 'RegistrantEventSignUp'

  # THROUGH
  has_many :event_choices, through: :registrant_choices
  has_many :events, through: :event_choices
  has_many :categories, through: :events
  has_many :volunteer_opportunities, through: :volunteer_choices

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
  accepts_nested_attributes_for :registrant_best_times, reject_if: :no_best_time_entered, allow_destroy: true
  accepts_nested_attributes_for :volunteer_choices

  before_create :create_associated_required_expense_items

  # always present validations
  before_validation :set_bib_number, on: :create
  validates :bib_number, presence: true
  validates :bib_number, uniqueness: true
  validates :registrant_type, inclusion: { in: RegistrantType::TYPES }, presence: true
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
  validates :status, inclusion: { in: statuses }, presence: true

  # Base details

  # necessary for all registrant types
  before_validation :set_sorted_last_name
  validates :first_name, :last_name, :sorted_last_name, presence: true
  validates :user_id, presence: true

  # necessary for comp/non-comp only (not spectators):
  with_options if: :comp_noncomp_past_step_1? do
    validates :birthday, :gender, presence: true
    validates :gender, inclusion: {in: %w[Male Female], message: "%{value} must be either 'Male' or 'Female'"}
    validate  :gender_present
    before_validation :set_age
    validates :age, presence: true
  end

  with_options if: %i[registrants_should_specify_default_wheel_size? comp_noncomp_past_step_1?] do
    before_validation :set_default_wheel_size
    validates :default_wheel_size, presence: true
    validate :check_default_wheel_size_for_age
  end

  # events
  validate :choices_combination_valid, if: :past_step_2?

  # waiver
  validates :online_waiver_acceptance, acceptance: { accept: true }, if: :needs_waiver?
  validates :rules_accepted, acceptance: { accept: true }, if: :needs_rules_accepted?

  # contact info
  validates_associated :contact_detail, if: :validated?
  validates_associated :registrant_best_times, if: :past_step_2?

  # Expense items
  validate :not_exceeding_expense_item_limits
  validates_associated :registrant_expense_items
  validate :has_necessary_free_items, if: :validated?

  scope :active_or_incomplete, -> { not_deleted.order(:bib_number) }
  scope :active, -> { where(status: "active").active_or_incomplete }
  scope :started, -> { where.not(status: "blank").active_or_incomplete}
  scope :not_deleted, -> { where(deleted: false) }

  def validated?
    status == "active"
  end

  def to_param
    bib_number.to_s if persisted?
  end

  RegistrantType::TYPES.each do |reg_type|
    # def competitor?
    #   registrant_type == 'competitor'
    # end
    define_method "#{reg_type}?" do
      registrant_type == reg_type
    end

    # def self.competitor
    #   where(registrant_type: 'competitor')
    # end
    define_singleton_method reg_type.to_s do
      where(registrant_type: reg_type)
    end
  end

  def registrant_type_model
    RegistrantType.for(registrant_type)
  end

  # uses the CachedSetModel feature to give a key for this registrant's competitors
  def members_cache_key
    Member.cache_key_for_set(id)
  end

  # updates the members, which update the competitors, if this competitor has changed (like their age, for example)
  def touch_members
    members.each do |mem|
      mem.touch
    end
  end

  # TODO: This should be extracted into a form helper?
  def self.select_box_options
    active.competitor.map{ |reg| [reg.with_id_to_s, reg.id] }
  end

  # TODO: This should be extracted into a form helper?
  def self.all_select_box_options
    started.map{ |reg| [reg.with_id_to_s, reg.id] }
  end

  # ##########################################################
  # TODO: Extract the following 4 methods into a collaborator
  # #########################################################
  #
  # Add a system-managed RegistrantExpenseItem, if it doesn't already exist
  def build_registration_item(reg_item)
    unless reg_item.nil? || has_expense_item?(reg_item)
      registrant_expense_items.system_managed.build(expense_item: reg_item)
    end
  end

  # Remove a system-managed RegistrantExpenseItem, if it exists
  def remove_registration_item(reg_item)
    unless reg_item.nil? || !has_expense_item?(reg_item)
      # registrant_expense_items.system_managed.find_by(expense_item_id: reg_item.id).destroy
      # use `.to_a` here so that we can use `mark_for_destruction` and it will be destroy on save
      item_to_remove = registrant_expense_items.to_a.find { |rei| rei.system_managed? && rei.expense_item == reg_item}
      item_to_remove.mark_for_destruction
    end
  end

  # for use when overriding the default system-managed reg_item
  def set_registration_item_expense(expense_item, lock = true)
    return true if reg_paid?
    curr_rei = registration_item

    if curr_rei.nil?
      curr_rei = build_registration_item(expense_item)
    end
    return false if curr_rei.nil?
    return true  if curr_rei.expense_item == expense_item && curr_rei.persisted?
    return true  if curr_rei.locked && !lock

    curr_rei.expense_item = expense_item
    curr_rei.locked = lock
    curr_rei.save
  end

  # determine if this registrant has an unpaid (or paid) version of this expense item
  def has_expense_item?(expense_item)
    all_expense_items.include?(expense_item)
  end

  # ##########################################################
  # END Extraction
  # ##########################################################

  def matching_competition_in_event(event)
    competitors.active.find{ |competitor| competitor.event == event }.try(:competition)
  end

  def create_associated_required_expense_items
    RequiredExpenseItemCreator.new(self).create
  end

  def registration_item
    all_reg_items = RegistrationCost.all_registration_expense_items
    registrant_expense_items.system_managed.find_by(expense_item_id: all_reg_items)
  end

  def wheel_size_id_for_event(event)
    competition_wheel_sizes.find{ |cws| cws.event_id == event.id }.try(:wheel_size_id) || wheel_size_id
  end

  # Public: Is this registrant young enough that they may need
  # to choose a wheel size?
  #
  # return a boolean
  def young_enough_to_choose_wheel_size?
    age <= EventConfiguration.singleton.wheel_size_configuration_max_age
  end

  def external_id
    bib_number
  end

  def minor?
    return false unless EventConfiguration.singleton.request_responsible_adult?
    return false if spectator?

    age < 18
  end

  def events_with_music_allowed
    signed_up_events.joins(:event).includes(:event).merge(Event.music_uploadable).map(&:event)
  end

  # for displaying on the Registrant#Summary page
  # if this user is signed up for an event category which is now "warning" flagged
  def event_warnings
    warned_sign_ups = signed_up_events.joins(:event_category).includes(:event, :event_category).merge(EventCategory.with_warnings)
    warned_sign_ups.map{|rei| "#{rei.event} - #{rei.event_category.name} Category" }
  end

  def has_standard_skill?
    signed_up_events.where(event: Event.standard_skill_events).any?
  end

  def name
    printed_name = full_name
    printed_name += " (incomplete)" unless validated?
    display_eligibility(printed_name, ineligible?)
  end

  def full_name
    first_name + " " + last_name
  end

  def email
    contact_detail.try(:email).try(:presence) || user.email
  end

  delegate :country_code, :country, :state, :club, to: :contact_detail, allow_nil: true

  # return an object describing the best time entered by this registrant
  def best_time(event)
    registrant_best_times.find_by(event: event) || registrant_choices.joins(:event_choice).merge(EventChoice.where(cell_type: "best_time", event: event)).first
  end

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

    paid? # read from the db column
  end

  def calculated_paid_status?
    return true if spectator?

    registration_cost_items = RegistrationCost.all_registration_expense_items
    paid_or_pending_expense_items.any? { |item| registration_cost_items.include?(item) }
  end

  # store the paid/not-paid status in a column, to make it MUCH easier to query
  def recalculate_paid!
    has_paid = calculated_paid_status?
    update(paid: has_paid) if paid != has_paid
  end

  # return a list of _ALL_ of the expense_items for this registrant
  #  PAID FOR or NOT
  def all_expense_items
    owing_expense_items + paid_expense_items + pending_expense_items
  end

  def amount_pending
    Rails.cache.fetch("/registrants/#{id}-#{updated_at}/amount_pending_money") do
      pending_details.inject(0.to_money) { |total, item| total + item.cost }
    end
  end

  def amount_owing
    Rails.cache.fetch("/registrants/#{id}-#{updated_at}/amount_owing_money") do
      registrant_expense_items.inject(0.to_money) { |total, item| total + item.total_cost }
    end
  end

  def expenses_total
    amount_owing + amount_paid + amount_pending
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

  def pending_expense_items
    pending_details.map{|pd| pd.expense_item }
  end

  def paid_or_pending_expense_items
    paid_expense_items + pending_expense_items
  end

  def paid_or_pending_details
    payment_details.includes(expense_item: [:translations, expense_group: :translations]).completed_or_offline.not_refunded.clone
  end

  def paid_details
    payment_details.includes(expense_item: [:translations, expense_group: :translations]).completed.not_refunded.clone
  end

  def pending_details
    payment_details.includes(expense_item: [:translations, expense_group: :translations]).offline_pending.not_refunded.clone
  end

  def amount_paid
    Rails.cache.fetch("/registrants/#{id}-#{updated_at}/amount_paid_money") do
      paid_details.inject(0.to_money){|total, item| total + item.cost}
    end
  end

  ############# Events Selection ########

  def active_competitors(event)
    competitors.includes(competition: :event).active.joins(:competition).where("competitions.event_id = ?", event)
  end

  def active_competitor(event)
    active_competitors(event).first
  end

  delegate :describe_event, :describe_event_hash, :describe_additional_selection, to: :presenter

  def presenter
    RegistrantPresenter.new(self)
  end

  def expense_item_is_free(expense_item)
    ExpenseItemFreeChecker.new(self, expense_item).expense_item_is_free?
  end

  def organization_membership_confirmed?
    return false unless validated?
    contact_detail.try(:organization_membership_confirmed?)
  end

  # Return a hash of categories, with values of a hash of event names
  # each event has a hash of details
  # Example:
  # {
  #   "Freestyle" => {
  #     "Individual" => {
  #       competition_name: "Individual",
  #       team_name: nil,
  #       additional_details: nil,
  #       confirmed: false,
  #       status: nil, # always 'nil' when !confirmed
  #     },
  #     "Pairs" =>
  #     {
  #       competition_name: "Novice Pairs",
  #       team_name: nil,
  #       additional_details: "Partner: Scott W",
  #       confirmed: true,
  #       status: "active", # possible values: ["active", "withdrawn", "dns", "not_qualified"]
  #     },
  #   },
  #   "Track" => {
  #     "100m" =>
  #     {
  #       competition_name: "100m",
  #       team_name: nil,
  #       additional_details: nil,
  #       confirmed: false,
  #       status: nil,
  #     }
  #   },
  # }
  def assigned_event_categories
    results = {}
    signed_up_events.includes(event: [event_choices: [:translations], category: [:translations]]).each do |registrant_sign_up|
      category_hash = results[registrant_sign_up.event.category.to_s] ||= {}
      event_hash = category_hash[registrant_sign_up.event.to_s] ||= {}
      event_hash[:competition_name] = registrant_sign_up.event.to_s
      event_hash[:team_name] = registrant_sign_up.event_category_name
      event_hash[:additional_details] = describe_additional_selection(registrant_sign_up.event)
      event_hash[:confirmed] = false
      event_hash[:status] = nil
    end

    competitors.includes(competition: [event: [category: [:translations]]]).each do |competitor|
      category_hash = results[competitor.event.category.to_s] ||= {}
      event_hash = category_hash[competitor.event.to_s] ||= {}
      event_hash[:competition_name] = competitor.competition.award_title
      event_hash[:team_name] = competitor.team_name
      event_hash[:age_group] = competitor.age_group_entry_description
      event_hash[:additional_details] = nil
      event_hash[:confirmed] = true
      event_hash[:status] = competitor.status
    end

    results
  end

  ############# Events Selection ########
  def has_event_in_category?(category)
    category.events.any?{|event| has_event?(event) }
  end

  # does this registrant have this event checked off?
  def has_event?(event)
    @has_event ||= {}
    @has_event[event] ||= signed_up_events.where(event_id: event.id).any?
  end

  private

  # Internal: Set the bib number of this registrant
  #
  def set_bib_number
    if bib_number.nil?
      self.bib_number = registrant_type_model.next_available_bib_number
    end
  end

  def set_age
    start_date = EventConfiguration.singleton.effective_age_calculation_base_date
    if start_date.nil? || birthday.nil?
      self.age = 99
    else
      self.age = age_at_event_date(start_date)
    end
  end

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
  # end Wizard

  # returns true if it should be rejected
  # but returns false if it exists, and needs to be cleared.
  def no_best_time_entered(attributes)
    if attributes['source_location'].blank? && attributes['formatted_value'].blank?
      if attributes['id'].present?
        attributes['_destroy'] = 1
        false
      else
        true
      end
    else
      false
    end
  end

  # ####################################
  # Event Choices Validation
  # ####################################
  def choices_combination_valid
    ChoicesValidator.new(self).validate
  end

  # Queue a job to query the USA db for membership information
  def update_usa_membership_status
    return unless last_name_changed?

    UpdateUsaMembershipStatusWorker.perform_async(id)
  end

  def set_access_code
    self.access_code ||= SecureRandom.hex(4)
  end

  def age_at_event_date(event_date)
    if (birthday.month < event_date.month) || (birthday.month == event_date.month && birthday.day <= event_date.day)
      event_date.year - birthday.year
    else
      (event_date.year - 1) - birthday.year
    end
  end

  def not_exceeding_expense_item_limits
    expense_items = registrant_expense_items.select(&:new_record?).map(&:expense_item).reject(&:nil?)
    expense_items.uniq.each do |ei|
      num_ei = expense_items.count(ei)
      unless ei.can_i_add?(num_ei)
        errors.add(:base, "There are not that many #{ei} available")
      end
    end
  end

  def has_necessary_free_items
    free_groups_required = registrant_type_model.required_free_expense_groups

    free_groups_required.each do |expense_group|
      if all_expense_items.none? { |expense_item| expense_item.expense_group == expense_group}
        errors.add(:base, "You must choose a free #{expense_group}")
      end
    end
  end

  def gender_present
    if gender.blank?
      errors.add(:gender_male, "") # Cause the label to be highlighted
      errors.add(:gender_female, "") # Cause the label to be highlighted
    end
  end

  def set_sorted_last_name
    self.sorted_last_name = ActiveSupport::Inflector.transliterate(last_name).downcase if last_name
  end

  def no_payments_when_deleted
    if paid_details.count.positive? && deleted?
      errors.add(:base, "Cannot delete a registration which has completed payments (refund them before deleting the registrant)")
    end
  end

  # indicate whether this registrant needs to set a default_wheel_size
  def registrants_should_specify_default_wheel_size?
    EventConfiguration.singleton.registrants_should_specify_default_wheel_size?
  end

  def set_default_wheel_size
    if default_wheel_size.nil?
      if young_enough_to_choose_wheel_size?
        self.default_wheel_size = WheelSize.find_by(description: "20\" Wheel")
      else
        self.default_wheel_size = WheelSize.find_by(description: "24\" Wheel")
      end
    end
  end

  def check_default_wheel_size_for_age
    max_config_age = EventConfiguration.singleton.wheel_size_configuration_max_age
    unless young_enough_to_choose_wheel_size?
      if default_wheel_size && default_wheel_size.description != "24\" Wheel"
        errors.add(:base, "You must choose a wheel size of 24\" if you are > #{max_config_age} years old")
      end
    end
  end
end
