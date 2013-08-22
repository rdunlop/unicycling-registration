class ExpenseItem < ActiveRecord::Base
  attr_accessible :cost, :description, :export_name, :name, :position, :expense_group_id, :has_details, :details_label, :maximum_available

  default_scope order('expense_group_id ASC, position ASC')

  validates :name, :description, :position, :cost, :expense_group, :presence => true
  validates :has_details, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :payment_details
  has_many :registrant_expense_items, :inverse_of => :expense_item

  belongs_to :expense_group

  before_destroy :check_for_payment_details

  after_initialize :init

  def init
    self.has_details = false if self.has_details.nil?
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

  def num_selected_items
    registrant_expense_items.size + payment_details.completed.count
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
