class Registrant < ActiveRecord::Base
  attr_accessible :address, :birthday, :city, :country, :email, :first_name, :gender, :last_name, :middle_initial, :mobile, :phone, :state, :zip
  attr_accessible :user_id, :competitor
  attr_accessible :club, :club_contact, :usa_member_number, :emergency_name, :emergency_relationship, :emergency_attending, :emergency_primary_phone, :emergency_other_phone
  attr_accessible :responsible_adult_name, :responsible_adult_phone

  validates :birthday, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :address, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :country, :presence => true
  validates :zip, :presence => true
  validates :gender, :presence => true
  validates :user_id, :presence => true
  before_validation :set_bib_number, :on => :create
  validates :bib_number, :presence => true

  validates :competitor, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}
  validates :deleted, :inclusion => {:in => [true, false] } # because it's a boolean
  validate  :gender_present

  # contact-info block
  validates :emergency_name, :presence => true
  validates :emergency_relationship, :presence => true
  validates :emergency_primary_phone, :presence => true
  validates :responsible_adult_name, :presence => true, :if => :minor?
  validates :responsible_adult_phone, :presence => true, :if => :minor?
  validate :no_payments_when_deleted

  has_paper_trail :meta => { :registrant_id => :id, :user_id => :user_id }

  belongs_to :user

  # may move into another object
  attr_accessible :registrant_choices_attributes
  has_many :registrant_choices, :dependent => :destroy, :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_choices

  attr_accessible :registrant_event_sign_ups_attributes
  has_many :registrant_event_sign_ups, :dependent => :destroy , :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_event_sign_ups

  validate :choices_are_all_set_or_none_set

  has_many :event_choices, :through => :registrant_choices
  has_many :events, :through => :event_choices
  has_many :categories, :through => :events

  attr_accessible :registrant_expense_items_attributes
  has_many :registrant_expense_items, :include => :expense_item
  has_many :expense_items, :through => :registrant_expense_items
  accepts_nested_attributes_for :registrant_expense_items, :allow_destroy => true # XXX destroy?

  default_scope where(:deleted => false)

  has_many :payment_details, :include => :payment

  has_many :time_results, :dependent => :destroy

  has_one :standard_skill_routine, :dependent => :destroy

  has_many :additional_registrant_accesses, :dependent => :destroy

  belongs_to :wheel_size

  after_initialize :init


  def set_bib_number
    if self.bib_number.nil?
      if self.competitor
        prev_value = Registrant.unscoped.where({:competitor => true}).maximum("bib_number")
        if prev_value.nil?
          self.bib_number = 1
        else
          self.bib_number = prev_value + 1
        end
      else
        prev_value = Registrant.unscoped.where({:competitor => false}).maximum("bib_number")
        if prev_value.nil?
          self.bib_number = 2001
        else
          self.bib_number = prev_value + 1
        end
      end
    end
  end

  def default_wheel_size
    if self.wheel_size.nil?
      if self.age > 10
        WheelSize.find_by_description("24\" Wheel")
      else
        WheelSize.find_by_description("20\" Wheel")
      end
    else
      self.wheel_size
    end
  end

  def external_id
    bib_number
  end

  def init
    self.deleted = false if self.deleted.nil?
  end

  def gender_present
    if gender.blank?
      errors[:gender_male] = "" # Cause the label to be highlighted
      errors[:gender_female] = "" # Cause the label to be highlighted
    end
  end

  def no_payments_when_deleted
    if self.payment_details.count > 0 and self.deleted
      errors[:base] << "Cannot delete a registration which has payments (started or completed)"
    end
  end

  def choices_are_all_set_or_none_set
    # for each event that we have choices made
     # determine if we have values for ALL or NONE of the choices for that event
    # loop
    sign_up_events = self.registrant_event_sign_ups.map{|resu| resu.event}
    choice_events = self.registrant_choices.map{|rc| rc.event_choice}.map{|ec| ec.event}

    events_to_validate = sign_up_events + choice_events

    events_to_validate.uniq.each do |event|
      count_not_selected = 0
      count_selected = 0

      primary_choice_selected = self.registrant_event_sign_ups.select {|resu| resu.event_id == event.id}.first
      if primary_choice_selected.nil? or not primary_choice_selected.signed_up
        event_selected = false
      else
        event_selected = true
      end

      event.event_choices.each do |event_choice|
        # using .select instead of .where, because we need to validate not-yet-saved data
        reg_choice = self.registrant_choices.select{|rc| rc.event_choice_id == event_choice.id}.first
        if reg_choice.nil? or not reg_choice.has_value?
          next if event_choice.cell_type == "boolean"
          count_not_selected += 1
        else
          count_selected += 1
        end
      end
      if (event_selected and count_not_selected != 0) or (!event_selected and count_selected != 0)
        # set the error message for each of the registrant_choices that we have
        event_reg_choices = self.registrant_choices.select{|rc| event.event_choices.include?(rc.event_choice)}
        event_reg_choices.each do |erc|
          erc.errors[:value] = "" # causes the field to be highlighted
          erc.errors[:event_category_id] = "" # causes the field to be highlighted
        end
        unless primary_choice_selected.nil?
          primary_choice_selected.errors[:signed_up] = "" # the primary checkbox
        end
        errors[:base] << event.to_s + " choice combination invalid (please fill them all or clear them all)"
      end
    end
    true
  end

  def minor?
    self.age < 18
  end

  def age
    Rails.cache.fetch("/registrants/#{id}-#{updated_at}/age") do
      start_date = EventConfiguration.start_date
      if start_date.nil? or self.birthday.nil?
        99
      else
        if (self.birthday.month < start_date.month) or (self.birthday.month == start_date.month and self.birthday.day <= start_date.day)
          start_date.year - self.birthday.year
        else
          (start_date.year - 1) - self.birthday.year
        end
      end
    end
  end

  def has_standard_skill?
    registrant_event_sign_ups.each do |rc|
      next if rc.event_category.nil?
      if rc.event_category.event.standard_skill?
        return rc.signed_up
      end
    end
    false
  end

  def name
    self.first_name + " " + self.last_name
  end

  def user_email
    user.email
  end

  def as_json(options={})
    options = {
      :only => [:first_name, :last_name, :gender, :birthday, :bib_number],
      :methods => [:user_email]
    }
    super(options)
  end

  def to_s
    name
  end

  ###### Expenses ##########

  # Indicates that this registrant has paid their registration_fee
  def reg_paid?
    reg_item = registration_item
    unless reg_item.nil?
      return paid_expense_items.include?(reg_item)
    end
    false
  end

  # ALL registrants
  def self.all_expense_items
    total = []
    Registrant.includes(:registrant_expense_items).includes(:payment_details).each do |reg|
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
    items = self.all_expense_items

    if items.size > 0
      total = items.map {|item| item.cost} .reduce(:+)
    else
      total = 0
    end
  end


  # returns a list of expense_items that this registrant hasn't paid for
  # INCLUDING the registration cost
  def owing_expense_items
    items = self.owing_expense_items_with_details.map{|eid| eid.first}
  end

  # pass back the details too, so that we don't mis-associate them when building the payment
  def owing_expense_items_with_details
    items = self.registrant_expense_items.map{|rei| [rei.expense_item, rei.details]}

    unless reg_paid?
      reg_item = registration_item
      unless reg_item.nil?
        items << [registration_item, nil]
      end
    end
    items
  end

  # returns a list of paid-for expense_items
  def paid_expense_items
    details = self.payment_details.select {|pd| pd.payment.completed == true } .map{|pd| pd.expense_item }
  end

  def amount_paid
    items = self.paid_expense_items
    if items.size > 0
      total = items.map {|item| item.cost} .reduce(:+)
    else
      total = 0
    end
  end


  def registration_item
    paid_reg_period = RegistrationPeriod.paid_for_period(self.competitor, self.paid_expense_items)
    unless paid_reg_period.nil?
      rp = paid_reg_period
    else
      rp = RegistrationPeriod.relevant_period(Date.today)
    end

    unless rp.nil?
      if self.competitor
        registration_expense_item = rp.competitor_expense_item
      else
        registration_expense_item = rp.noncompetitor_expense_item
      end
    end
    registration_expense_item
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
    self.registrant_event_sign_ups.where({:event_id => event.id, :signed_up => true}).any?
  end

  def describe_event(event)
    description = event.name

    resu = registrant_event_sign_ups.where({:event_id => event.id, :signed_up => true}).first
    # only add the Category if there are more than 1
    if event.event_categories.count > 1
      description += " - Category: " + resu.event_category.to_s unless resu.nil?
    end

    event.event_choices.each do |ec|
      my_val = self.registrant_choices.where({:event_choice_id => ec.id}).first
      unless my_val.nil?
        description += " - " + ec.label + ": " + my_val.describe_value
      end
    end
    description
  end
end
