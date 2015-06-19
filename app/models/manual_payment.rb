class ManualPaymentDetail
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :registrant_expense_item_id, Integer
  attribute :pay_for, Boolean
  validates :registrant_expense_item_id, presence: true

  # these are derived from the REI
  delegate :registrant_id, :expense_item_id, :free, :total_cost, :details, to: :registrant_expense_item

  def initialize(params = {})
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  def registrant_expense_item
    RegistrantExpenseItem.find(registrant_expense_item_id)
  end

  def registrant
    Registrant.find(registrant_id)
  end

  def expense_item
    ExpenseItem.find(expense_item_id)
  end

  def persisted?
    false
  end
end

class ManualPayment
  # this is an admin payment
  #
  # references
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  # http://stackoverflow.com/questions/972857/multiple-objects-in-a-rails-form
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :note, String

  attribute :user, User
  attribute :saved_payment, Payment
  validates :note, presence: true
  validate :at_least_one_paid_element

  def at_least_one_paid_element
    return if unpaid_details.any? { |el| el.pay_for? }
    errors[:base] = "At least one element must be marked paid for"
  end

  def add_registrant(registrant)
    registrant.owing_registrant_expense_items.each do |rei|
      next if rei.free
      @new_expense_items << ManualPaymentDetail.new(registrant_expense_item_id: rei.id)
    end
  end

  def initialize(params = {})
    @new_expense_items = []
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  def unpaid_details
    @new_expense_items
  end

  def unpaid_details_attributes=(params = {})
    params.values.each do |detail|
      @new_expense_items << ManualPaymentDetail.new(detail)
    end
  end

  def persisted?
    false
  end

  def build_payment_detail(payment, new_detail)
    if new_detail.pay_for
      detail = payment.payment_details.build
      detail.free = new_detail.free
      detail.amount = new_detail.total_cost
      detail.registrant_id = new_detail.registrant_id
      detail.expense_item_id = new_detail.expense_item_id
      detail.details = new_detail.details
    end
  end

  def build_payment
    payment = Payment.new
    payment.note = note

    unpaid_details.each do |ud|
      build_payment_detail(payment, ud)
    end
    payment.completed = true
    payment.completed_date = DateTime.now
    payment.user = user
    payment
  end

  def save
    return false if invalid?
    payment = build_payment
    return false if payment.invalid? # how to show when this fails?

    self.saved_payment = payment
    payment.save
  end
end
