class ExpenseItem < ActiveRecord::Base
  attr_accessible :cost, :description, :export_name, :name, :position, :expense_group_id, :has_details, :details_label, :maximum_available , :tax_percentage

  default_scope order('expense_group_id ASC, position ASC')

  validates :name, :description, :position, :cost, :expense_group, :tax_percentage, :presence => true
  validates :has_details, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :tax_percentage, :numericality => {:greater_than_or_equal_to => 0} 

  has_many :payment_details
  has_many :registrant_expense_items, :inverse_of => :expense_item


  translates :name, :description, :details_label
  accepts_nested_attributes_for :translations
  attr_accessible :translations_attributes

  belongs_to :expense_group, :inverse_of => :expense_items

  before_destroy :check_for_payment_details

  after_initialize :init

  def init
    self.has_details = false if self.has_details.nil?
    self.tax_percentage = 0 if self.tax_percentage.nil?
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
    registrant_expense_items.count + payment_details.completed.count
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
