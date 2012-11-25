class Registrant < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :birthday, :city, :country, :email, :first_name, :gender, :last_name, :middle_initial, :mobile, :phone, :state, :zip_code, :user_id, :competitor

  validates :birthday, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :city, :presence => true
  validates :country, :presence => true
  validates :gender, :presence => true
  validates :user_id, :presence => true

  validates :competitor, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :gender, :inclusion => {:in => %w(Male Female), :message => "%{value} must be either 'Male' or 'Female'"}


  belongs_to :user

  # may move into another object
  attr_accessible :registrant_choices_attributes
  has_many :registrant_choices, :dependent => :destroy #, :inverse_of :registrant
  accepts_nested_attributes_for :registrant_choices

  has_many :event_choices, :through => :registrant_choices
  has_many :events, :through => :event_choices
  has_many :categories, :through => :events
  has_many :payment_details


  def name
    self.first_name + " " + self.last_name
  end

  def registration_cost
    rp = RegistrationPeriod.relevant_period(Date.today)
    if rp.nil?
      0
    else
      if self.competitor
        return rp.competitor_cost
      else
        return rp.noncompetitor_cost
      end
    end
  end

  def amount_owing
    return self.registration_cost - self.amount_paid
  end

  def amount_paid
    total = 0
    self.payment_details.each do |pd|
      if pd.payment.completed
        total += pd.amount
      end
    end
    total
  end

  def to_s
    name
  end

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
