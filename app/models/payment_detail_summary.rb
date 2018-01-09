class PaymentDetailSummary
  # references
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  # http://stackoverflow.com/questions/972857/multiple-objects-in-a-rails-form
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attribute :count, Integer

  attribute :line_item_id, Integer
  attribute :line_item_type, String
  attribute :payment_id, Integer
  attribute :amount, Decimal

  def payment
    Payment.find(payment_id)
  end

  def payment=(payment)
    self.payment_id = payment.id
  end

  def line_item
    line_item_type.constantize.find(line_item_id)
  end

  def line_item=(item)
    self.line_item_id = item.id
    self.line_item_type = item.class.name
  end

  delegate :to_s, to: :line_item

  def persisted?
    false
  end

  def ==(other)
    other.count == count &&
      other.payment_id == payment_id &&
      other.line_item_id == line_item_id &&
      other.line_item_type == line_item_type &&
      other.amount == amount
  end
end
