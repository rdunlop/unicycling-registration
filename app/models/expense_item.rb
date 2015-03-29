# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean          default(FALSE), not null
#  maximum_available      :integer
#  has_custom_cost        :boolean          default(FALSE), not null
#  maximum_per_registrant :integer          default(0)
#  cost_cents             :integer
#  tax_cents              :integer          default(0), not null
#
# Indexes
#
#  index_expense_items_expense_group_id  (expense_group_id)
#

class ExpenseItem < ActiveRecord::Base
  validates :name, :position, :cost, :expense_group, :presence => true
  validates :has_details, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :has_custom_cost, :inclusion => { :in => [true, false] } # because it's a boolean

  monetize :tax_cents, :cost_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_cost_cents

  has_many :payment_details, dependent: :restrict_with_error
  has_many :registrant_expense_items, :inverse_of => :expense_item, dependent: :restrict_with_error
  has_many :coupon_code_expense_items, dependent: :destroy

  translates :name, :details_label, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  belongs_to :expense_group, :inverse_of => :expense_items
  validates :expense_group_id, :uniqueness => true, :if => "(expense_group.try(:competitor_required) == true) or (expense_group.try(:noncompetitor_required) == true)"

  before_destroy :check_for_payment_details

  after_create :create_reg_items

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
      Registrant.noncompetitor.each do |reg|
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

  def total_cost_cents
    (cost_cents + tax_cents) if cost_cents && tax_cents
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

  def has_limits?
    return true if maximum_available && maximum_available > 0
    return true if maximum_per_registrant && maximum_per_registrant > 0
    false
  end
end
