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
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#  competitor              :boolean
#  deleted                 :boolean
#  bib_number              :integer
#  wheel_size_id           :integer
#  age                     :integer
#  ineligible              :boolean          default(FALSE)
#  volunteer               :boolean
#  online_waiver_signature :string(255)
#

class Registrant < ActiveRecord::Base
  include Eligibility

  has_one :contact_detail, dependent: :destroy, autosave: true, :inverse_of => :registrant
  accepts_nested_attributes_for :contact_detail
  validates_associated :contact_detail

  validates :first_name, :last_name, :birthday, :gender, :presence => true

  validates :user_id, :presence => true
  before_validation :set_bib_number, :on => :create
  validates :bib_number, :presence => true

  validates :competitor, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}
  validates :ineligible, :inclusion => {:in => [true, false] } # because it's a boolean
  validates :deleted, :inclusion => {:in => [true, false] } # because it's a boolean
  validate  :gender_present

  # contact-info block
  validate :no_payments_when_deleted

  validates :online_waiver_signature, :presence => true, :unless => "EventConfiguration.has_online_waiver == false"

  has_paper_trail :meta => { :registrant_id => :id, :user_id => :user_id }

  # may move into another object
  has_many :registrant_choices, :dependent => :destroy, :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_choices

  has_many :registrant_event_sign_ups, :dependent => :destroy , :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_event_sign_ups
  has_many :signed_up_events, -> { where ["signed_up = ?", true ] }, :class_name => 'RegistrantEventSignUp'

  validate :choices_combination_valid

  has_many :event_choices, :through => :registrant_choices
  has_many :events, :through => :event_choices
  has_many :categories, :through => :events

  has_many :registrant_expense_items, -> { includes :expense_item}, :dependent => :destroy
  has_many :expense_items, :through => :registrant_expense_items
  accepts_nested_attributes_for :registrant_expense_items, :allow_destroy => true # XXX destroy?
  before_create :create_associated_required_expense_items
  validate :not_exceeding_expense_item_limits
  validates_associated :registrant_expense_items

  has_many :payment_details, -> {includes :payment}, :dependent => :destroy
  has_many :payments, :through => :payment_details
  has_many :refund_details, :through => :payment_details
  has_many :refunds, :through => :refund_details

  has_many :registrant_group_members, :dependent => :destroy
  has_many :registrant_groups, :through => :registrant_group_members

  # For event competitions/results
  has_many :members, :dependent => :destroy
  has_many :competitors, :through => :members
  has_many :competitions, :through => :competitors

  has_one :standard_skill_routine, :dependent => :destroy

  has_many :additional_registrant_accesses, :dependent => :destroy

  has_many :songs, :dependent => :destroy

  before_validation :set_age
  validates :age, :presence => true

  before_validation :set_default_wheel_size
  belongs_to :default_wheel_size, :class_name => "WheelSize", :foreign_key => :wheel_size_id
  validates :default_wheel_size, :presence => true
  validate :check_default_wheel_size_for_age

  after_save(:touch_members)

  belongs_to :user

  scope :active, -> { where(:deleted => false).order(:bib_number) }

  # updates the members, which update the competitors, if this competitor has changed (like their age, for example)
  def touch_members
    members.each do |mem|
      mem.touch
    end
  end

  def self.select_box_options
    self.active.where(:competitor => true).map{ |reg| [reg.with_id_to_s, reg.id] }
  end

  def build_registration_item(reg_item)
    unless reg_item.nil? or has_expense_item?(reg_item)
      registrant_expense_items.build(:expense_item => reg_item, :system_managed => true)
    end
  end

  def create_associated_required_expense_items

    # add the registration_period expense_item
    rp = RegistrationPeriod.relevant_period(Date.today)
    unless rp.nil? or reg_paid?
      if competitor
        reg_item = rp.competitor_expense_item
      else
        reg_item = rp.noncompetitor_expense_item
      end
      build_registration_item(reg_item)
    end

    required_expense_items.each do |ei|
      unless has_expense_item?(ei)
        registrant_expense_items.build(:expense_item => ei, :system_managed => true)
      end
    end
  end

  # determine if this registrant has an unpaid (or paid) version of this expense item
  def has_expense_item?(expense_item)
    all_expense_items.include?(expense_item)
  end

  # any items which have a required element, but only 1 element in the group (no choices allowed by the registrant)
  def required_expense_items
    if competitor
      egs = ExpenseGroup.where({:competitor_required => true})
    else
      egs = ExpenseGroup.where({:noncompetitor_required => true})
    end

    req_eis = []
    egs.each do |eg|
      if eg.expense_items.count == 1
        req_eis << eg.expense_items.first
      end
    end
    req_eis
  end


  after_initialize :init

  # Creates the registrant owing
  def build_owing_payment(payment)
    reg_items = owing_registrant_expense_items
    reg_items.each do |reg_item|
      next if reg_item.free
      item = reg_item.expense_item
      details = reg_item.details
      pd = payment.payment_details.build()
      pd.registrant = self
      pd.amount = reg_item.total_cost
      pd.expense_item = item
      pd.details = details
      pd.free = reg_item.free
    end
  end

  def registration_item
    all_reg_items = RegistrationPeriod.all_registration_expense_items
    registrant_expense_items.where({:system_managed => true, :expense_item_id => all_reg_items}).first
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
    unscoped.where({:competitor => is_competitor}).maximum("bib_number")
  end

  def set_bib_number
    if self.bib_number.nil?
      prev_value = Registrant.maximum_bib_number(self.competitor)

      if self.competitor
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

  def set_default_wheel_size
    if self.default_wheel_size.nil?
      if self.age > 10
        self.default_wheel_size = WheelSize.find_by_description("24\" Wheel")
      else
        self.default_wheel_size = WheelSize.find_by_description("20\" Wheel")
      end
    end
  end

  def check_default_wheel_size_for_age
    if self.age > 10
      if default_wheel_size && self.default_wheel_size.description != "24\" Wheel"
        errors[:base] << "You must choose a wheel size of 24\" if you are > 10 years old"
      end
    end
  end

  def external_id
    bib_number
  end

  def init
    self.deleted = false if self.deleted.nil?
    self.ineligible = false if self.ineligible.nil?
    self.volunteer = false if self.volunteer.nil?
  end

  def gender_present
    if gender.blank?
      errors[:gender_male] = "" # Cause the label to be highlighted
      errors[:gender_female] = "" # Cause the label to be highlighted
    end
  end

  def no_payments_when_deleted
    if self.payment_details.completed.count > 0 and self.deleted
      errors[:base] << "Cannot delete a registration which has completed payments (refund them before deleting the registrant)"
    end
  end


  # ####################################
  # Event Choices Validation
  # ####################################
  def choices_combination_valid
    # for each event that we have choices made
    # determine if we have values for ALL or NONE of the choices for that event
    # loop
    sign_up_events = self.registrant_event_sign_ups.map{|resu| resu.event}
    choice_events = self.registrant_choices.map{|rc| rc.event_choice}.map{|ec| ec.event}

    events_to_validate = sign_up_events + choice_events

    events_to_validate.uniq.each do |event|
      validate_event event
    end

    true
  end

  def signed_up_for(event)
    primary_choice_selected = self.registrant_event_sign_ups.select {|resu| resu.event_id == event.id}.first
    if primary_choice_selected.nil? or not primary_choice_selected.signed_up
      event_selected = false
    else
      event_selected = true
    end
    event_selected
  end

  def mark_event_sign_up_as_error(event)
    primary_choice_selected = self.registrant_event_sign_ups.select {|resu| resu.event_id == event.id}.first
    primary_choice_selected.errors[:signed_up] = "" unless primary_choice_selected.nil? # the primary checkbox
  end

  def get_choice_for_event_choice(event_choice)
    self.registrant_choices.select{|rc| rc.event_choice_id == event_choice.id}.first
  end

  def validate_event(event)
    event_selected = signed_up_for(event)
    event.event_choices.each do |event_choice|
      # using .select instead of .where, because we need to validate not-yet-saved data
      reg_choice = get_choice_for_event_choice(event_choice)

      if !valid_event_choice_registrant_choice(event_selected, event_choice, reg_choice)
        mark_event_sign_up_as_error(event)
      end
    end
  end

  def valid_event_choice_registrant_choice(event_selected, event_choice, reg_choice)
    optional_if_event_choice = event_choice.optional_if_event_choice
    required_if_event_choice = event_choice.required_if_event_choice

    if event_selected && !valid_with_required_selection(event_choice, reg_choice)
      errors[:base] << "#{event_choice.to_s } must be specified if #{required_if_event_choice.to_s} is chosen"
      return false
    end

    if event_selected && !valid_with_optional_selection(event_choice, reg_choice)
      errors[:base] << "#{event_choice.to_s } must be specified unless #{optional_if_event_choice.to_s} is chosen"
      return false
    end

    return true if event_choice.optional
    return true if optional_if_event_choice.present? # we passed the optional check, so we shouldn't complain
    return true if required_if_event_choice.present? # we passed the required check, so we shouldn't complain

    if event_selected
      if reg_choice.nil? or not reg_choice.has_value?
        return true if event_choice.cell_type == "boolean"
        errors[:base] << "#{event_choice.to_s} must be specified"
        reg_choice.errors[:value] = "" unless reg_choice.nil?
        reg_choice.errors[:event_category_id] = "" unless reg_choice.nil?
        return false
      end
    else
      if reg_choice.present? and reg_choice.has_value?
        errors[:base] << "#{event_choice.to_s} cannot be specified if the event isn't chosen"
        reg_choice.errors[:value] = "" unless reg_choice.nil?
        reg_choice.errors[:event_category_id] = "" unless reg_choice.nil?
        return false
      end
    end
    true
  end

  def valid_with_required_selection(event_choice, reg_choice)
    required_if_event_choice = event_choice.required_if_event_choice

    unless required_if_event_choice.nil?
      reg_choice_has_value = reg_choice.present? && reg_choice.has_value?

      required_reg_choice = get_choice_for_event_choice(required_if_event_choice)
      required_has_value = required_reg_choice.present? && required_reg_choice.has_value?

      if required_has_value
        # the required choice IS selected
        if !reg_choice_has_value
          # the choice isn't selected, and the -required- element is chosen
          return false
        end
      end
    end
    true
  end

  def valid_with_optional_selection(event_choice, reg_choice)
    return true if event_choice.optional
    optional_if_event_choice = event_choice.optional_if_event_choice

    # check to see if this is optional by way of another choice
    unless optional_if_event_choice.nil?
      reg_choice_has_value = reg_choice.present? && reg_choice.has_value?

      optional_reg_choice = get_choice_for_event_choice(optional_if_event_choice)
      optional_has_value = optional_reg_choice.present? && optional_reg_choice.has_value?

      if not optional_has_value
        # the optional choice isn't selected
        if not reg_choice_has_value
          # this option is NOT selected, but the optional ISN'T either
          return false
        end
      else
        # the optional choice IS selected
        # it doesn't matter whether we have a chosen value or not
        return true
      end
    end
    true
  end

  def minor?
    self.age < 18
  end

  def set_age
    start_date = EventConfiguration.start_date
    if start_date.nil? or self.birthday.nil?
      self.age = 99
    else
      if (self.birthday.month < start_date.month) or (self.birthday.month == start_date.month and self.birthday.day <= start_date.day)
        self.age = start_date.year - self.birthday.year
      else
        self.age = (start_date.year - 1) - self.birthday.year
      end
    end
  end

  def has_standard_skill?
    signed_up_events.each do |rc|
      next if rc.event_category.nil?
      if rc.event_category.event.standard_skill?
        return true
      end
    end
    false
  end

  def name
    full_name = self.first_name + " " + self.last_name
    display_eligibility(full_name, ineligible)
  end

  def user_email
    user.email
  end

  delegate :country_code, :country, :club, to: :contact_detail, allow_nil: true

  def as_json(options={})
    options = {
      :only => [:first_name, :last_name, :gender, :birthday, :bib_number],
      :methods => [:user_email]
    }
    super(options)
  end

  def to_s
    name + (deleted ? " (deleted)" : "")
  end

  def with_id_to_s
    bib_number.to_s + "-" + to_s
  end


  ###### Expenses ##########

  # Indicates that this registrant has paid their registration_fee
  def reg_paid?
    Rails.cache.fetch("/registrant/#{id}-#{updated_at}/reg_paid") do
      if RegistrationPeriod.paid_for_period(self.competitor, self.paid_expense_items).nil?
        false
      else
        true
      end
    end
  end

  # ALL registrants
  def self.all_expense_items
    total = []
    Registrant.includes(registrant_expense_items: [:expense_item]).includes(payment_details: [:payment, :expense_item]).each do |reg|
      total += reg.all_expense_items
    end
    total
  end

  # return a list of _ALL_ of the expense_items for this registrant
  #  PAID FOR or NOT
  def all_expense_items
    items  = owing_expense_items
    items += paid_expense_items

    items
  end

  def amount_owing
    return self.expenses_total - self.amount_paid
  end

  def expenses_total
    items = self.owing_registrant_expense_items
    items += self.paid_details

    if items.size > 0
      total = items.map {|item| item.cost} .reduce(:+)
    else
      total = 0
    end
  end


  # returns a list of expense_items that this registrant hasn't paid for
  # INCLUDING the registration cost
  def owing_expense_items
    self.owing_registrant_expense_items.map{|eid| eid.expense_item}
  end

  # pass back the details too, so that we don't mis-associate them when building the payment
  def owing_expense_items_with_details
    self.owing_registrant_expense_items.map{|rei| [rei.expense_item, rei.details]}
  end

  def owing_registrant_expense_items
    # prevents this from creating new items when we return a 'new'd element
    self.registrant_expense_items.clone
  end

  def has_required_expense_group(expense_group)
    paid_details.select { |pd| pd.expense_item.expense_group == expense_group }.count > 0
  end

  # returns a list of paid-for expense_items
  def paid_expense_items
    paid_details.map{|pd| pd.expense_item }
  end

  def paid_details
    self.payment_details.completed.clone
  end

  def amount_paid
    items = self.paid_details
    if items.size > 0
      total = items.map {|item| item.cost} .reduce(:+)
    else
      total = 0
    end
  end

  ############# Events Selection ########
  def has_event_in_category?(category)
    category.events.each do |ev|
      if self.has_event?(ev)
        return true
      end
    end
    false
  end

  # does this registrant have this event checked off?
  def has_event?(event)
    self.signed_up_events.where({:event_id => event.id}).any?
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

    resu = signed_up_events.where({:event_id => event.id}).first
    # only add the Category if there are more than 1
    results[:category] = nil
    if event.event_categories.count > 1
      results[:category] = resu.event_category.name.to_s unless resu.nil?
    end

    results[:additional] = nil
    event.event_choices.each do |ec|
      my_val = self.registrant_choices.where({:event_choice_id => ec.id}).first
      unless my_val.nil? or !my_val.has_value?
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

    return false
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

    return false
  end

  def expense_item_is_free(expense_item)
    if competitor
      case expense_item.expense_group.competitor_free_options
      when "One Free In Group"
        return !has_chosen_free_item_from_expense_group(expense_item.expense_group)
      when "One Free of Each In Group"
        return !has_chosen_free_item_of_expense_item(expense_item)
      end
    else
      case expense_item.expense_group.noncompetitor_free_options
      when "One Free In Group"
        return !has_chosen_free_item_from_expense_group(expense_item.expense_group)
      when "One Free of Each In Group"
        return !has_chosen_free_item_of_expense_item(expense_item)
      end
    end

    return false
  end

  def not_exceeding_expense_item_limits
    expense_items = registrant_expense_items.map{|rei| rei.new_record? ? rei.expense_item : nil}.reject { |ei| ei.nil? }
    expense_items.uniq.each do |ei|
      num_ei = expense_items.count(ei)
      if !ei.can_i_add?(num_ei)
        errors[:base] << "There are not that many #{ei.to_s} available"
      end
    end
  end
end
