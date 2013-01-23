class ExpenseItem < ActiveRecord::Base
  attr_accessible :cost, :description, :export_name, :name, :position, :expense_group_id

  validates :name, :presence => true
  validates :description, :presence => true
  validates :position, :presence => true
  validates :cost, :presence => true
  validates :expense_group, :presence => true

  has_many :payment_details

  belongs_to :expense_group

  before_destroy :check_for_payment_details

  def check_for_payment_details
    if payment_details.count > 0
      errors[:base] << "cannot delete expense_item containing a matching payment"
      return false
    end
  end

  def to_s
    self.expense_group.to_s + " - " + name
  end
end
