# == Schema Information
#
# Table name: payments
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  completed            :boolean          default(FALSE), not null
#  cancelled            :boolean          default(FALSE), not null
#  transaction_id       :string(255)
#  completed_date       :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  payment_date         :string(255)
#  note                 :string(255)
#  invoice_id           :string(255)
#  offline_pending      :boolean          default(FALSE), not null
#  offline_pending_date :datetime
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

class Payment < ActiveRecord::Base
  include CachedModel

  scope :completed, -> { where(completed: true) }
  scope :completed_or_offline, -> { where("completed = TRUE or offline_pending = TRUE") }

  validates :user_id, presence: true
  validate :transaction_id_or_note
  validates_associated :payment_details

  has_paper_trail

  belongs_to :user
  has_many :payment_details, inverse_of: :payment, dependent: :destroy
  accepts_nested_attributes_for :payment_details, reject_if: proc { |attributes| attributes['registrant_id'].blank? }, allow_destroy: true

  before_validation :set_invoice_id
  validates :invoice_id, presence: true, uniqueness: true

  after_save :update_registrant_items
  after_save :touch_payment_details
  after_save :inform_of_coupons

  def set_invoice_id
    self.invoice_id ||= SecureRandom.hex(10)
  end

  def completed_or_offline?
    completed? || offline_pending?
  end

  def touch_payment_details
    payment_details.each do |pd|
      pd.touch
    end
  end

  def just_completed_or_offline_payment?
    (completed? && completed_changed?) || (offline_pending? && offline_pending_changed?)
  end

  def inform_of_coupons
    return true unless just_completed_or_offline_payment?

    payment_details.map(&:inform_of_coupon)
  end

  def details
    return "(Offline Payment Pending)" if offline_pending?

    unless transaction_id.blank?
      return transaction_id
    end

    unless note.blank?
      return note
    end

    nil
  end

  def complete(options = {})
    assign_attributes(options)
    self.completed_date = DateTime.current
    self.completed = true
    save
  end

  # Mark this payment as "will be paid offline"
  def offline_pay
    self.offline_pending_date = DateTime.current
    self.offline_pending = true
    save
  end

  def transaction_id_or_note
    if completed?
      if details.nil?
        errors[:base] << "Transaction ID or Note must be filled in"
      end
    end
  end

  def update_registrant_items
    return true unless just_completed_or_offline_payment?

    payment_details.each do |pd|
      rei = RegistrantExpenseItem.find_by(registrant_id: pd.registrant.id, expense_item_id: pd.expense_item.id, free: pd.free, details: pd.details)
      unless pd.details.nil?
        if rei.nil? && pd.details.empty?
          rei = RegistrantExpenseItem.find_by(registrant_id: pd.registrant.id, expense_item_id: pd.expense_item.id, free: pd.free, details: nil)
        end
      end

      if rei.nil?
        # this is used when PayPal eventually approves a payment, but the registration
        # period has moved forward, and we have changed the associated registration_item?
        all_reg_items = RegistrationCost.all_registration_expense_items
        if all_reg_items.include?(pd.expense_item)
          # the pd is a reg_item, see if there is another reg_item in the registrant's list
          rei = pd.registrant.registration_item
        end
      end

      if rei.nil?
        PaymentMailer.missing_matching_expense_item(id).deliver_later
      else
        rei.destroy
      end
    end
  end

  # return a set of payment_details which are unique With-respect-to {amount, expense_item }
  def unique_payment_details
    results = []
    payment_details.each do |pd|
      res = nil
      results.each do |r|
        if r.expense_item_id == pd.expense_item_id && r.amount == pd.amount
          res = r
          break
        end
      end

      if res.nil?
        results << PaymentDetailSummary.new(expense_item_id: pd.expense_item_id, count: 1, amount: pd.amount)
      else
        res.count += 1
      end
    end
    results
  end

  def paypal_post_url
    EventConfiguration.paypal_base_url + "/cgi-bin/webscr"
  end

  def total_amount
    Money.new(payment_details.reduce(0.to_money) { |memo, pd| memo + pd.cost })
  end

  def self.total_non_refunded_amount
    total = 0.to_money
    PaymentDetail.refunded.includes(:payment).each do |payment_detail|
      total += payment_detail.cost
    end
    total
  end

  def self.total_received
    total = 0.to_money
    Payment.includes(payment_details: [:refund_detail]).completed.each do |payment|
      total += payment.total_amount
    end
    total
  end

  def self.paid_details
    all = []
    Registrant.all.find_each do |reg|
      all += reg.paid_details
    end
    all
  end

  def self.paid_expense_items
    all = []
    Registrant.includes(payment_details: [:expense_item]).each do |reg|
      all += reg.paid_expense_items
    end
    all
  end

  def self.build_from_details(options)
    payment = Payment.new(
      completed: true,
      note: options[:note],
      completed_date: DateTime.now
    )
    payment.payment_details.build(
      registrant: options[:registrant],
      expense_item: options[:item],
      details: options[:details],
      amount: options[:amount],
      free: false
    )
    payment
  end
end
