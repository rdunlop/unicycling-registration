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
#  cost_element_id        :integer
#  cost_element_type      :string
#
# Indexes
#
#  index_expense_items_expense_group_id                          (expense_group_id)
#  index_expense_items_on_cost_element_type_and_cost_element_id  (cost_element_type,cost_element_id)
#

class ExpenseItem < ActiveRecord::Base
  validates :name, :cost, :expense_group, presence: true
  validates :has_details, inclusion: { in: [true, false] } # because it's a boolean
  validates :has_custom_cost, inclusion: { in: [true, false] } # because it's a boolean

  monetize :tax_cents, :cost_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_cost_cents

  # use Exception so that RegistrationCost is rolled back if it attempts to be destroyed
  has_many :payment_details, dependent: :restrict_with_exception

  has_many :registrant_expense_items, inverse_of: :expense_item, dependent: :restrict_with_exception
  has_many :coupon_code_expense_items, dependent: :destroy

  translates :name, :details_label, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  belongs_to :cost_element, polymorphic: true, inverse_of: :expense_item
  belongs_to :expense_group, inverse_of: :expense_items
  validates :expense_group_id, uniqueness: true, if: "(expense_group.try(:competitor_required) == true) or (expense_group.try(:noncompetitor_required) == true)"

  acts_as_restful_list scope: :expense_group

  before_destroy :check_for_payment_details

  after_create :create_reg_items
  after_create :create_cost_item_registrant_items

  def self.ordered
    order(:expense_group_id, :position)
  end

  def self.user_manageable
    joins(:expense_group).merge(ExpenseGroup.user_manageable)
  end

  # items paid for
  def paid_items
    payment_details.paid.where(refunded: false)
  end

  def refunded_items
    payment_details.paid.where(refunded: true)
  end

  def num_paid_with_coupon
    paid_items.with_coupon.count
  end

  def num_paid_without_coupon
    num_paid - num_paid_with_coupon
  end

  # How many of this expense item are free
  def num_free
    free_items.count
  end

  def free_items
    paid_free_items + free_items_with_reg_paid
  end

  # Items which are fully paid
  def num_paid
    paid_items.count
  end

  # how much have we received for the paid items
  def total_amount_paid
    Money.new(paid_items.map(&:cost).inject(:+))
  end

  def total_amount_paid_after_refunds
    Money.new(refunded_items.map(&:cost).inject(:+))
  end

  # Items which are unpaid.
  # Note: Free items which are associated with Paid Registrants are considered Paid/Free.
  def unpaid_items(include_incomplete_registrants: false)
    reis = if include_incomplete_registrants
             registrant_expense_items.joins(:registrant).merge(Registrant.active_or_incomplete)
           else
             registrant_expense_items.joins(:registrant).merge(Registrant.active)
           end
    reis.free.select{ |rei| !rei.registrant.reg_paid? } + reis.where(free: false)
  end

  def num_unpaid(include_incomplete_registrants: false)
    unpaid_items(include_incomplete_registrants: include_incomplete_registrants).count
  end

  # If this expense_item is part of a "Required" expense group
  # update any existing Registrant records to properly include the
  # newly-required items
  def create_reg_items
    if expense_group.competitor_required?
      Registrant.competitor.each do |reg|
        reg.build_registration_item(self)
        reg.save
      end
    end
    if expense_group.noncompetitor_required?
      Registrant.noncompetitor.each do |reg|
        reg.build_registration_item(self)
        reg.save
      end
    end
  end

  # if this expense_item is associated with a "CostElement" (e.g. Event)
  # (and soon to be RegistrationCost)
  # inform that element that it should create necessary RegistrantExpenseItems
  def create_cost_item_registrant_items
    if cost_element.present?
      cost_element.create_for_all_registrants
    end
  end

  def check_for_payment_details
    if payment_details.count > 0
      errors[:base] << "cannot delete expense_item containing a matching payment"
      return false
    end
  end

  def to_s
    if cost_element.present?
      cost_element.to_s
    else
      expense_group.to_s + " - " + name
    end
  end

  def total_cost_cents
    (cost_cents + tax_cents) if cost_cents && tax_cents
  end

  # How many of this item have been selected by registrants in total
  # Includes
  def num_selected_items
    num_unpaid(include_incomplete_registrants: true) + num_paid
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

  private

  def paid_free_items
    paid_items.free
  end

  def free_items_with_reg_paid
    registrant_expense_items.joins(:registrant).where(registrants: {deleted: false}).free.select{ |rei| rei.registrant.reg_paid? }
  end
end
