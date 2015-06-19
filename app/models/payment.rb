# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  completed      :boolean          default(FALSE), not null
#  cancelled      :boolean          default(FALSE), not null
#  transaction_id :string(255)
#  completed_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  payment_date   :string(255)
#  note           :string(255)
#  invoice_id     :string(255)
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

class Payment < ActiveRecord::Base
  include CachedModel

  scope :completed, -> { where(completed: true) }

  validates :user_id, presence: true
  validate :transaction_id_or_note
  validates_associated :payment_details

  has_paper_trail

  belongs_to :user
  has_many :payment_details, inverse_of: :payment, dependent: :destroy
  accepts_nested_attributes_for :payment_details, reject_if: proc { |attributes| attributes['registrant_id'].blank? }

  before_validation :set_invoice_id
  validates :invoice_id, presence: true, uniqueness: true

  after_save :update_registrant_items
  after_save :touch_payment_details
  after_save :inform_of_coupons

  def set_invoice_id
    self.invoice_id ||= SecureRandom.hex(10)
  end

  def touch_payment_details
    payment_details.each do |pd|
      pd.touch
    end
  end

  def just_completed?
    completed == true && self.completed_changed?
  end

  def inform_of_coupons
    return true unless just_completed?

    payment_details.map(&:inform_of_coupon)
  end

  def details
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
    self.completed_date = DateTime.now
    self.completed = true
    save
  end

  def transaction_id_or_note
    if completed
      if details.nil?
        errors[:base] << "Transaction ID or Note must be filled in"
      end
    end
  end

  def update_registrant_items
    return true unless just_completed?

    payment_details.each do |pd|
      rei = RegistrantExpenseItem.where({registrant_id: pd.registrant.id, expense_item_id: pd.expense_item.id, free: pd.free, details: pd.details}).first
      unless pd.details.nil?
        if rei.nil? && pd.details.empty?
          rei = RegistrantExpenseItem.where({registrant_id: pd.registrant.id, expense_item_id: pd.expense_item.id, free: pd.free, details: nil}).first
        end
      end

      if rei.nil?
        all_reg_items = RegistrationPeriod.all_registration_expense_items
        if all_reg_items.include?(pd.expense_item)
          # the pd is a reg_item, see if there is another reg_item in the registrant's list
          rei = pd.registrant.registration_item
        end
      end

      unless rei.nil?
        rei.destroy
      else
        PaymentMailer.missing_matching_expense_item(id).deliver_later
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
        results << PaymentDetailSummary.new({expense_item_id: pd.expense_item_id, count: 1, amount: pd.amount})
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
    payment_details.reduce(0) { |memo, pd| memo + pd.cost }.to_f
  end

  def self.total_received
    total = 0
    Payment.includes(payment_details: [:refund_detail]).completed.each do |payment|
      total += payment.total_amount
    end
    total
  end

  def self.paid_details
    all = []
    Registrant.all.each do |reg|
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
      completed_date: DateTime.now,
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
