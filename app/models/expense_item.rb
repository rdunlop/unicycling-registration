class ExpenseItem < ActiveRecord::Base
  default_scope order('expense_group_id ASC, position ASC')

  validates :name, :description, :position, :cost, :expense_group, :tax_percentage, :presence => true
  validates :has_details, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :tax_percentage, :numericality => {:greater_than_or_equal_to => 0} 


  has_many :payment_details
  has_many :registrant_expense_items, :inverse_of => :expense_item


  translates :name, :description, :details_label
  accepts_nested_attributes_for :translations

  belongs_to :expense_group, :inverse_of => :expense_items
  validates :expense_group_id, :uniqueness => true, :if => "(expense_group.try(:competitor_required) == true) or (expense_group.try(:noncompetitor_required) == true)"

  before_destroy :check_for_payment_details

  after_create :create_reg_items

  after_initialize :init

  def init
    self.has_details = false if self.has_details.nil?
    self.tax_percentage = 0 if self.tax_percentage.nil?
  end

  def num_paid
    payment_details.completed.count
  end

  def num_unpaid
    rp = RegistrationPeriod.relevant_period(Date.today)
    unless rp.nil?
      if self == rp.competitor_expense_item
        count = Registrant.where({:competitor => true}).all.count {|reg| !reg.reg_paid? }
        return count
      elsif self == rp.noncompetitor_expense_item
        count = Registrant.where({:competitor => false}).all.count {|reg| !reg.reg_paid? }
        return count
      end
    end

    registrant_expense_items.count
  end

  def create_reg_items
    if self.expense_group.competitor_required
      Registrant.where({:competitor => true}).each do |reg|
        reg.registrant_expense_items.build({:expense_item_id => self.id, :system_managed => true})
        reg.save
      end
    end
    if self.expense_group.noncompetitor_required
      Registrant.where({:competitor => false}).each do |reg|
        reg.registrant_expense_items.build({:expense_item_id => self.id, :system_managed => true})
        reg.save
      end
    end
  end

  def check_for_payment_details
    if payment_details.count > 0
      errors[:base] << "cannot delete expense_item containing a matching payment"
      return false
    end
  end

  def to_s
    self.expense_group.to_s + " - " + name
  end

  # round the taxes to the next highest penny
  def tax
    raw_tax_cents = (cost * (tax_percentage/100.0)) * 100
    fractions_of_penny = ((raw_tax_cents).to_i - (raw_tax_cents) != 0)

    tax_cents = raw_tax_cents.to_i
    if fractions_of_penny
      tax_cents += 1
    end
    tax_cents / 100.0
  end

  def total_cost
    cost + tax
  end

  def num_selected_items
    registrant_expense_items.count + num_paid
  end

  def can_i_add?(num_to_add)
    if maximum_available.nil?
      true
    else
      num_selected_items + num_to_add <= maximum_available
    end
  end

  def maximum_reached?
    if maximum_available.nil?
      false
    else
      num_selected_items >= maximum_available
    end
  end
end
