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



  after_save :touch_members


  after_initialize :init


  has_paper_trail :meta => { :registrant_id => :id, :user_id => :user_id }

  has_one :contact_detail, dependent: :destroy, autosave: true, :inverse_of => :registrant
  has_one :standard_skill_routine, :dependent => :destroy

  # may move into another object
  has_many :registrant_choices, :dependent => :destroy, :inverse_of => :registrant
  has_many :registrant_event_sign_ups, :dependent => :destroy , :inverse_of => :registrant
  has_many :signed_up_events, -> { where ["signed_up = ?", true ] }, :class_name => 'RegistrantEventSignUp'
  has_many :registrant_expense_items, -> { includes :expense_item}, :dependent => :destroy

  has_many :payment_details, -> {includes :payment}, :dependent => :destroy
  has_many :additional_registrant_accesses, :dependent => :destroy
  has_many :registrant_group_members, :dependent => :destroy
  has_many :songs, :dependent => :destroy

  # THROUGH
  has_many :event_choices, :through => :registrant_choices
  has_many :events, :through => :event_choices
  has_many :categories, :through => :events

  has_many :expense_items, :through => :registrant_expense_items

  has_many :payments, :through => :payment_details
  has_many :refund_details, :through => :payment_details
  has_many :refunds, :through => :refund_details

  has_many :registrant_groups, :through => :registrant_group_members

  # For event competitions/results
  has_many :members, :dependent => :destroy
  has_many :competitors, :through => :members
  has_many :competitions, :through => :competitors


  belongs_to :default_wheel_size, :class_name => "WheelSize", :foreign_key => :wheel_size_id
  belongs_to :user

  accepts_nested_attributes_for :contact_detail
  accepts_nested_attributes_for :registrant_expense_items, :allow_destroy => true # XXX destroy?
  accepts_nested_attributes_for :registrant_choices
  accepts_nested_attributes_for :registrant_event_sign_ups


  before_create :create_associated_required_expense_items


  before_validation :set_bib_number, :on => :create
  before_validation :set_age
  before_validation :set_default_wheel_size

  validates_associated :contact_detail
  validates_associated :registrant_expense_items

  validates :first_name, :last_name, :birthday, :gender, :presence => true
  validates :user_id, :bib_number, :age, :default_wheel_size, :presence => true

  validates :competitor, :ineligible, :deleted, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}
  validate  :gender_present

  validates :online_waiver_signature, :presence => true, :if => "EventConfiguration.has_online_waiver"
  validate :no_payments_when_deleted

  validate :choices_combination_valid
  validate :not_exceeding_expense_item_limits
  validate :check_default_wheel_size_for_age



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
    unless reg_item.nil? || has_expense_item?(reg_item)
      registrant_expense_items.build(:expense_item => reg_item, :system_managed => true)
    end
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
    where({:competitor => is_competitor}).maximum("bib_number")
  end

  def set_bib_number
    if bib_number.nil?
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
    if paid_details.count > 0 && self.deleted
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
      RegistrationPeriod.paid_for_period(self.competitor, paid_expense_items).present?
    end
  end

  # return a list of _ALL_ of the expense_items for this registrant
  #  PAID FOR or NOT
  def all_expense_items
    owing_expense_items + paid_expense_items
  end

  def amount_owing
    registrant_expense_items.inject(0){|total, item| total + item.cost}
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
    # prevents this from creating new items when we return a 'new'd element
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
    paid_details.inject(0){|total, item| total + item.cost}
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
    @has_event ||= {}
    @has_event[event] ||= self.signed_up_events.where({:event_id => event.id}).any?
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
