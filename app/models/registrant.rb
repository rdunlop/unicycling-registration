class Registrant < ActiveRecord::Base
  validates :first_name, :last_name, :birthday, :gender, :presence => true
  validates :address, :city, :country_residence, :zip, :presence => true

  validates :state, :presence => true, :unless => "EventConfiguration.usa == false"

  validates :user_id, :presence => true
  before_validation :set_bib_number, :on => :create
  validates :bib_number, :presence => true

  validates :competitor, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}
  validates :ineligible, :inclusion => {:in => [true, false] } # because it's a boolean
  validates :deleted, :inclusion => {:in => [true, false] } # because it's a boolean
  validate  :gender_present

  # contact-info block
  validates :emergency_name, :emergency_relationship, :emergency_primary_phone, :presence => true
  validates :responsible_adult_name, :responsible_adult_phone, :presence => true, :if => :minor?
  validate :no_payments_when_deleted

  has_paper_trail :meta => { :registrant_id => :id, :user_id => :user_id }

  belongs_to :user

  # may move into another object
  has_many :registrant_choices, :dependent => :destroy, :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_choices

  has_many :registrant_event_sign_ups, :dependent => :destroy , :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_event_sign_ups
  has_many :signed_up_events, :class_name => 'RegistrantEventSignUp', :conditions => ['signed_up = ?', true]

  validate :choices_are_all_set_or_none_set

  has_many :event_choices, :through => :registrant_choices
  has_many :events, :through => :event_choices
  has_many :categories, :through => :events

  has_many :registrant_expense_items, :include => :expense_item, :dependent => :destroy
  has_many :expense_items, :through => :registrant_expense_items
  accepts_nested_attributes_for :registrant_expense_items, :allow_destroy => true # XXX destroy?
  before_create :create_associated_required_expense_items
  validate :not_exceeding_expense_item_limits
  validates_associated :registrant_expense_items

  default_scope where(:deleted => false).order(:bib_number)

  has_many :payment_details, :include => :payment

  has_many :registrant_group_members, :dependent => :destroy
  has_many :registrant_groups, :through => :registrant_group_members

  # For event competitions/results
  has_many :members, :dependent => :destroy
  has_many :competitors, :through => :members
  has_many :competitions, :through => :competitors

  has_one :standard_skill_routine, :dependent => :destroy

  has_many :additional_registrant_accesses, :dependent => :destroy

  before_validation :set_age
  validates :age, :presence => true

  before_validation :set_default_wheel_size
  belongs_to :default_wheel_size, :class_name => "WheelSize", :foreign_key => :wheel_size_id
  validates :default_wheel_size, :presence => true

  after_save(:touch_members)

  # updates the members, which update the competitors, if this competitor has changed (like their age, for example)
  def touch_members
    members.each do |mem|
      mem.touch
    end
  end

  def create_associated_required_expense_items
    # add the registration_period expense_item


    # create any items which have a required element, but only 1 element in the group (no choices allowed by the registrant)
    if competitor
      egs = ExpenseGroup.where({:competitor_required => true}).all
    else
      egs = ExpenseGroup.where({:noncompetitor_required => true}).all
    end

    egs.each do |eg|
      if eg.expense_items.count == 1
        registrant_expense_items.build({:expense_item_id => eg.expense_items.first.id, :system_managed => true})
      end
    end
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

  def has_complex_double_free
    has_double_free(false)
  end

  def has_double_free(simple = true)
    owing = registrant_expense_items.select {|rei| rei.free }.map {|rei| rei.expense_item}

    has_paid_free_item = false
    all_matching = true

    details = paid_details.where({:free =>true})
    return false if details.count == 0
    if details.count != owing.count
      return false if simple
      return true if !simple
    end
    details.each do |pd|

      has_paid_free_item = true
      if owing.include?(pd.expense_item)
        # has a paid item which IS in the owing set
      else
        # has a paid item which IS NOT in the owing set
        all_matching = false
      end
    end
    return false unless has_paid_free_item

    if simple
      return all_matching
    else
      return !all_matching
    end
  end

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

  def set_default_wheel_size
    if self.default_wheel_size.nil?
      if self.age > 10
        self.default_wheel_size = WheelSize.find_by_description("24\" Wheel")
      else
        self.default_wheel_size = WheelSize.find_by_description("20\" Wheel")
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

      primary_choice_selected = self.registrant_event_sign_ups.select {|resu| resu.event_id == event.id}.first
      if primary_choice_selected.nil? or not primary_choice_selected.signed_up
        event_selected = false
      else
        event_selected = true
      end

      event.event_choices.each do |event_choice|
        # using .select instead of .where, because we need to validate not-yet-saved data
        reg_choice = self.registrant_choices.select{|rc| rc.event_choice_id == event_choice.id}.first
        next if event_choice.optional
        optional_if_event_choice = event_choice.optional_if_event_choice

        # check to see if this is optional by way of another choice
        unless optional_if_event_choice.nil?
          optional_reg_choice = self.registrant_choices.select{|rc| rc.event_choice_id == optional_if_event_choice.id}.first
          if optional_reg_choice.nil? or not optional_reg_choice.has_value?
            # the optional choice isn't selected
            if reg_choice.nil? or not reg_choice.has_value?
              # this option is NOT selected, but the optional ISN'T either
              next if not event_selected
              errors[:base] << "#{event_choice.to_s } must be specified unless #{optional_if_event_choice.to_s} is chosen"
              primary_choice_selected.errors[:signed_up] = "" unless primary_choice_selected.nil? # the primary checkbox
              next
            end
          else
            # the optional choice IS selected
            if reg_choice.nil? or not reg_choice.has_value?
              # this option IS NOT selected, and the optional choice IS selected
              #  DO NOTHING, as this is allowed by 'optional_if'
              next
            else
              # this option IS selected, and the optional Choice IS selected
               # ensure that we haven't chosen-without-event by falling through
            end
          end
        end

        if reg_choice.nil? or not reg_choice.has_value?
          next if event_choice.cell_type == "boolean"
          if event_selected
            errors[:base] << "#{event_choice.to_s} must be specified"
            reg_choice.errors[:value] = "" unless reg_choice.nil?
            reg_choice.errors[:event_category_id] = "" unless reg_choice.nil?
            primary_choice_selected.errors[:signed_up] = "" unless primary_choice_selected.nil? # the primary checkbox
          end
        else
          if not event_selected
            errors[:base] << "#{event_choice.to_s} cannot be specified if the event isn't chosen"
            reg_choice.errors[:value] = "" unless reg_choice.nil?
            reg_choice.errors[:event_category_id] = "" unless reg_choice.nil?
            primary_choice_selected.errors[:signed_up] = "" unless primary_choice_selected.nil? # the primary checkbox
          end
        end
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
    if ineligible
      self.first_name + " " + self.last_name + "*"
    else
      self.first_name + " " + self.last_name
    end
  end

  def user_email
    user.email
  end

  def country
    if self.country_representing.nil? or self.country_representing.empty?
      self.country_residence
    else
      self.country_representing
    end
  end

  def country_name
    Carmen::Country.coded(self.country_residence).try(:name)
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
    items = self.owing_registrant_expense_items.map{|eid| eid.expense_item}
  end

  # pass back the details too, so that we don't mis-associate them when building the payment
  def owing_expense_items_with_details
    items = self.owing_registrant_expense_items.map{|rei| [rei.expense_item, rei.details]}
  end

  def owing_registrant_expense_items
    # prevents this from creating new items when we return a 'new'd element
    items = self.registrant_expense_items.clone

    if not reg_paid?
      ri = registration_item
      if not ri.nil?
        items << RegistrantExpenseItem.new({:registrant_id => self.id, :expense_item_id => ri.id})
      end
    end


    items
  end

  def has_required_expense_group(expense_group)
    paid_details.select { |pd| pd.expense_item.expense_group == expense_group }.count > 0
  end

  # returns a list of paid-for expense_items
  def paid_expense_items
    details = paid_details.map{|pd| pd.expense_item }
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

  def registration_item
    unless reg_paid?
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

    results[:age_group] = nil
    unless resu.nil?
      agt = resu.event_category.age_group_type
      results[:age_group] = agt.age_group_entry_description(age, gender, default_wheel_size.id) unless agt.nil?
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
