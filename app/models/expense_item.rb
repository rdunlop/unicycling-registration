class ExpenseItem < ActiveRecord::Base
  attr_accessible :cost, :description, :export_name, :name, :position, :expense_group_id, :has_details, :details_label

  default_scope order('expense_group_id ASC, position ASC')

  validates :name, :description, :position, :cost, :expense_group, :presence => true
  validates :has_details, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :payment_details

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
end
