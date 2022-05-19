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
#  index_expense_items_on_cost_element_type_and_cost_element_id  (cost_element_type,cost_element_id) UNIQUE
#

class ExpenseItem < ApplicationRecord
  validates :name, :cost, :expense_group, presence: true
  validates :has_details, inclusion: { in: [true, false] } # because it's a boolean
  validates :has_custom_cost, inclusion: { in: [true, false] } # because it's a boolean

  monetize :tax_cents, :cost_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :total_cost_cents

  # use Exception so that RegistrationCost is rolled back if it attempts to be destroyed
  has_many :payment_details, as: :line_item, dependent: :restrict_with_exception

  has_many :registrant_expense_items, as: :line_item, inverse_of: :line_item, dependent: :restrict_with_exception
  has_many :coupon_code_expense_items, dependent: :destroy

  translates :name, :details_label, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  belongs_to :cost_element, polymorphic: true, inverse_of: :expense_item
  belongs_to :expense_group, inverse_of: :expense_items
  validate :must_be_free, if: :exactly_one_in_group_required?
  validates :expense_group_id, uniqueness: {
    message: "- You cannot add a 2nd item to this Expense Group. Using the Expense Group option 'competitor/non-competitor required' means only ONE item can exist in this expense group"
  }, if: -> { (expense_group.try(:competitor_required) == true) || (expense_group.try(:noncompetitor_required) == true) }

  acts_as_list scope: :expense_group

  before_destroy :check_for_payment_details

  after_create :create_reg_items
  after_create :create_cost_item_registrant_items

  def self.for_event
    where(cost_element_type: "Event")
  end

  def self.ordered
    order(:expense_group_id, :position)
  end

  def self.user_manageable
    joins(:expense_group).merge(ExpenseGroup.user_manageable)
  end

  def self.any_in_use?
    where("cost_cents > 0").any?
  end

  # items paid for
  def paid_items
    payment_details.paid.where(refunded: false)
  end

  def refunded_items
    payment_details.paid.where(refunded: true)
  end

  def pending_items
    payment_details.offline_pending
  end

  def num_paid_with_coupon
    paid_items.with_coupon.count
  end

  def num_paid_without_coupon
    num_paid - num_paid_with_coupon
  end

  def num_pending
    pending_items.count
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
             registrant_expense_items.includes(:registrant).joins(:registrant).merge(Registrant.active_or_incomplete)
           else
             registrant_expense_items.includes(:registrant).joins(:registrant).merge(Registrant.active)
           end
    reis.free.reject { |rei| rei.registrant.reg_paid? } + reis.where(free: false)
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
    if payment_details.count.positive?
      errors.add(:base, "cannot delete expense_item containing a matching payment")
      throw(:abort)
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

  # return an array of errors which should prevent creating the passed registrant_expense_item
  def can_create_registrant_expense_item?(registrant_expense_item)
    errors = []

    max = maximum_per_registrant.to_i
    if max.positive?
      if registrant_expense_item.registrant.all_line_items.count(self) == max
        errors << "Each Registrant is only permitted #{max} of #{self}"
      end
    end

    if registrant_expense_item.free?
      free_item_checker = ExpenseItemFreeChecker.new(registrant_expense_item.registrant, self)
      if free_item_checker.free_item_already_exists?
        errors << free_item_checker.error_message
      end
    end

    unless can_i_add?(1)
      errors << "There are not that many #{self} available"
    end

    errors
  end

  def can_i_add?(num_to_add)
    return true if maximum_available.nil?
    return true unless has_limits?

    num_selected_items + num_to_add <= maximum_available
  end

  def maximum_reached?
    return false if maximum_available.nil?
    return false unless has_limits?

    num_selected_items >= maximum_available
  end

  def has_limits?
    return true if maximum_available&.positive?
    return true if maximum_per_registrant&.positive?

    false
  end

  def free_items_with_reg_paid
    registrant_expense_items.includes(:registrant).joins(:registrant).where(registrants: { deleted: false }).free.select { |rei| rei.registrant.reg_paid? }
  end

  # If the coupon is for the associated LodgingRoomOption
  def valid_coupon?(coupon_line_item)
    coupon_line_item == self
  end

  private

  def paid_free_items
    payment_details.completed.where(refunded: false).free
  end

  def must_be_free
    return if cost_cents.to_i.zero?

    errors.add(:cost, "Must be free if in using an expense group with the exactly_one option")
  end

  def exactly_one_in_group_required?
    return if expense_group.blank?

    expense_group.expense_group_options.any? do |ego|
      ego.option == ExpenseGroupOption::EXACTLY_ONE_IN_GROUP_REQUIRED
    end
  end
end
