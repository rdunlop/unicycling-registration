class Registrant < ActiveRecord::Base
  attr_accessible :birthday, :country, :email, :first_name, :gender, :last_name, :middle_initial, :mobile, :phone, :state, :user_id, :competitor
  attr_accessible :club, :club_contact, :usa_member_number, :emergency_name, :emergency_relationship, :emergency_attending, :emergency_primary_phone, :emergency_other_phone
  attr_accessible :responsible_adult_name, :responsible_adult_phone

  validates :birthday, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :country, :presence => true
  validates :gender, :presence => true
  validates :user_id, :presence => true

  validates :competitor, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}

  # contact-info block
  validates :emergency_name, :presence => true
  validates :emergency_relationship, :presence => true
  validates :emergency_primary_phone, :presence => true

  has_paper_trail :meta => { :registrant_id => :id, :user_id => :user_id }

  belongs_to :user

  # may move into another object
  attr_accessible :registrant_choices_attributes
  has_many :registrant_choices, :dependent => :destroy, :inverse_of => :registrant
  accepts_nested_attributes_for :registrant_choices

  has_many :event_choices, :through => :registrant_choices
  has_many :events, :through => :event_choices
  has_many :categories, :through => :events

  attr_accessible :registrant_expense_items_attributes
  has_many :registrant_expense_items
  has_many :expense_items, :through => :registrant_expense_items
  accepts_nested_attributes_for :registrant_expense_items, :allow_destroy => true # XXX destroy?

  has_many :payment_details

  def name
    self.first_name + " " + self.last_name
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
    items = self.registrant_expense_items.map{|rei| rei.expense_item}

    unless reg_paid?
      reg_item = registration_item
      unless reg_item.nil?
        items << registration_item
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
    enablement_choice = event.event_choices.where({:position => 1})
    if enablement_choice.empty?
      false
    else
      my_val = self.registrant_choices.where({:event_choice_id => enablement_choice.first.id}).first
      if my_val.nil?
        false
      else
        my_val.value == "1"
      end
    end
  end

  def describe_event(event)
    description = event.name

    event.event_choices.each do |ec|
      if ec.position != 1
        my_val = self.registrant_choices.where({:event_choice_id => ec.id}).first
        unless my_val.nil?
          description += " - " + ec.label + ": " + my_val.value
        end
      end
    end
    description
  end
end
