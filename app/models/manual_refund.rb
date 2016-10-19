class ManualRefundDetail
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :paid_detail_id, Integer
  attribute :refund, Boolean
  validates :paid_detail_id, presence: true

  # these are derived from the REI
  delegate :registrant_id, :expense_item_id, :free, :cost, :details, to: :paid_detail

  def initialize(params = {})
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  def paid_detail
    PaymentDetail.find(paid_detail_id)
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

class ManualRefund
  # this is an admin refund
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
  attribute :percentage, Integer
  validates :note, :percentage, presence: true
  validate :at_least_one_refunded_element

  attr_accessor :items

  def at_least_one_refunded_element
    if items.none? { |el| el.refund? }
      errors.add(:base, "At least one element must be marked refunded")
    end
  end

  def add_registrant(registrant)
    registrant.paid_details.each do |pd|
      @items << ManualRefundDetail.new(paid_detail_id: pd.id)
    end
  end

  def initialize(params = {})
    @items = []
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  def items_attributes=(params = {})
    params.values.each do |detail|
      @items << ManualRefundDetail.new(detail)
    end
  end

  def persisted?
    false
  end

  def save
    return false if invalid?
    refund = build_refund
    return false if refund.invalid?

    refund.save
  end

  private

  def build_refund
    refund = Refund.new
    refund.note = note
    refund.percentage = percentage

    items.each do |pd|
      if pd.refund
        detail = refund.refund_details.build()
        detail.payment_detail_id = pd.paid_detail_id
      end
    end
    refund.refund_date = DateTime.now
    refund.user = user
    refund
  end
end
