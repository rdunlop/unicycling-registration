class PaymentPresenter
  # this is an admin payment
  #
  # references
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  # http://stackoverflow.com/questions/972857/multiple-objects-in-a-rails-form
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attribute :note, String

  attribute :user, User
  attribute :saved_payment, Payment
  attr_accessor :existing_payment_details

  def add_registrant(registrant)
    registrant.owing_registrant_expense_items.each do |rei|
      next if rei.free

      @new_expense_items << PaymentDetailPresenter.new(registrant_id: rei.registrant.id, line_item: rei.line_item, free: rei.free, amount: rei.total_cost, details: rei.details)
    end
    registrant.paid_details.each do |pd|
      @existing_payment_details << PaymentDetailPresenter.new(registrant_id: pd.registrant.id, line_item: pd.line_item, free: pd.free, amount: pd.amount, details: pd.details)
    end
  end

  def initialize(params = {})
    @existing_payment_details = []
    @new_expense_items = []
    @new_details = []
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  class PaymentDetailPresenter
    include Virtus.model

    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :registrant_id, Integer
    attribute :line_item_id, Integer
    attribute :line_item_type, String
    attribute :details, String

    attribute :amount, Decimal
    attribute :free, Boolean

    validates :registrant_id, presence: true

    def initialize(params = {})
      params.each do |name, value|
        send("#{name}=", value)
      end
    end

    def registrant
      Registrant.find(registrant_id)
    end

    def line_item=(new_item)
      self.line_item_id = new_item.id
      self.line_item_type = new_item.class.name
    end

    def line_item
      return nil if line_item_type.blank? || line_item_id.blank?

      line_item_type.constantize.find(line_item_id)
    end

    def cost
      if free
        0
      else
        line_item.total_cost
      end
    end

    def persisted?
      false
    end
  end

  def paid_details
    @existing_payment_details
  end

  def paid_details_attributes=(params = {})
    params.each_value do |detail|
      @existing_payment_details << PaymentDetailPresenter.new(detail)
    end
  end

  def unpaid_details
    @new_expense_items
  end

  def unpaid_details_attributes=(params = {})
    params.each_value do |detail|
      @new_expense_items << PaymentDetailPresenter.new(detail)
    end
  end

  def new_details
    if @new_details.empty?
      5.times do
        @new_details << PaymentDetailPresenter.new
      end
    end
    @new_details
  end

  def new_details_attributes=(params = {})
    params.each_value do |detail|
      @new_details << PaymentDetailPresenter.new(detail)
    end
  end

  def registrants
    regs = paid_details.map { |nd| nd.registrant }
    unregs = unpaid_details.map { |ud| ud.registrant }
    (regs + unregs).uniq
  end

  def persisted?
    false
  end

  # delegate to the underlying payment
  def errors
    p = build_payment
    p.valid?
    p.errors
  end

  # validate based on the undelying payment validation
  def valid?
    p = build_payment
    p.valid?
  end

  def build_payment_detail(payment, new_detail)
    if new_detail.free
      detail = payment.payment_details.build
      detail.free = new_detail.free
      detail.amount = new_detail.cost
      detail.registrant_id = new_detail.registrant_id
      detail.line_item = new_detail.line_item
      detail.details = new_detail.details
    end
  end

  def build_payment
    payment = Payment.new
    payment.note = note

    unpaid_details.each do |ud|
      build_payment_detail(payment, ud)
    end
    new_details.each do |nd|
      build_payment_detail(payment, nd)
    end
    payment.completed = true
    payment.completed_date = Time.current
    payment.user = user
    payment
  end

  def save
    # XXX any way to have this automatically call valid? (instead of me having to do so?)
    payment = build_payment
    valid?
    return false unless payment.valid?

    self.saved_payment = payment
    payment.save
  end
end
