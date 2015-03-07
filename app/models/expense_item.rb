# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  cost                   :decimal(, )
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean
#  details_label          :string(255)
#  maximum_available      :integer
#  tax_percentage         :decimal(5, 3)    default(0.0)
#  has_custom_cost        :boolean          default(FALSE)
#  maximum_per_registrant :integer          default(0)
#
# Indexes
#
#  index_expense_items_expense_group_id  (expense_group_id)
#

class ExpenseItem < ActiveRecord::Base

  validates :name, :position, :cost, :expense_group, :tax_percentage, :presence => true
  validates :has_details, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :has_custom_cost, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :tax_percentage, :numericality => {:greater_than_or_equal_to => 0}

  has_many :payment_details, dependent: :restrict_with_error
  has_many :registrant_expense_items, :inverse_of => :expense_item, dependent: :restrict_with_error
  has_many :coupon_code_expense_items, dependent: :destroy

  translates :name, :details_label
  accepts_nested_attributes_for :translations

  belongs_to :expense_group, :inverse_of => :expense_items
  validates :expense_group_id, :uniqueness => true, :if => "(expense_group.try(:competitor_required) == true) or (expense_group.try(:noncompetitor_required) == true)"

  before_destroy :check_for_payment_details

  after_create :create_reg_items

  after_initialize :init

  def init
    self.has_details = false if self.has_details.nil?
    self.tax_percentage = 0 if self.tax_percentage.nil?
    self.has_custom_cost = false if self.has_custom_cost.nil?
  end

  def self.ordered
    order(:expense_group_id, :position)
  end

  def self.user_manageable
    includes(:expense_group).where(expense_groups: { registration_items: false })
  end


  # items paid for
  def paid_items
    payment_details.paid.where(refunded: false)
  end

  def num_paid_with_coupon
    paid_items.with_coupon.count
  end

  def num_paid_without_coupon
    num_paid - num_paid_with_coupon
  end

  def num_paid
    paid_items.count
  end

  # how much have we received for the paid items
  def total_amount_paid
    paid_items.map(&:cost).inject(:+).to_f
  end

  def free_items
    payment_details.free
  end

  def num_free
    free_items.count
  end

  def unpaid_items
    registrant_expense_items.joins(:registrant).where(:registrants => {:deleted => false})
  end

  def num_unpaid
    unpaid_items.count
  end

  def create_reg_items
    if self.expense_group.competitor_required
      Registrant.competitor.each do |reg|
        reg.build_registration_item(self)
        reg.save
      end
    end
    if self.expense_group.noncompetitor_required
      Registrant.notcompetitor.each do |reg|
        reg.build_registration_item(self)
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
    (cost + tax).round(2)
  end

  def num_selected_items
    num_unpaid + num_paid
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
