class PaymentDetailSummary
  # references
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  # http://stackoverflow.com/questions/972857/multiple-objects-in-a-rails-form
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attribute :count, Integer

  attribute :expense_item_id, Integer
  attribute :payment_id, Integer
  attribute :amount, Decimal

  def payment
    Payment.find(payment_id)
  end

  def payment=(payment)
    self.payment_id = payment.id
  end

  def expense_item
    ExpenseItem.find(expense_item_id)
  end

  def expense_item=(item)
    self.expense_item_id = item.id
  end

  def to_s
    expense_item.to_s
  end

  def persisted?
    false
  end

  def ==(other)
    other.count == self.count &&
      other.payment_id == self.payment_id &&
      other.expense_item_id == self.expense_item_id &&
      other.amount == self.amount
  end
end
