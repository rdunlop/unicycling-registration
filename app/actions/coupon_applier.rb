class CouponApplier
  attr_accessor :payment, :coupon_code_string, :error, :applied_count

  def initialize(payment, coupon_code_string)
    @payment = payment
    @coupon_code_string = coupon_code_string.downcase
  end

  def perform
    unless coupon_code
      self.error = "Coupon Code not found"
      return false
    end
    @applied_count = 0

    CouponCode.transaction do
      payment.payment_details.each do |pd|
        apply_coupon(pd) unless pd.payment_detail_coupon_code
      end
    end

    if applied_count == 0
      self.error ||= "Coupon Code not applicable to this order"
    end

    self.error.nil?
  end

  private

  def apply_coupon(payment_detail)
    return unless coupon_code_applies_to?(payment_detail.expense_item)

    if coupon_limit_reached?
      self.error = "Coupon limit reached"
    else
      payment_detail.create_payment_detail_coupon_code(coupon_code: coupon_code)
      payment_detail.recalculate!
      @applied_count += 1
    end
  end

  def coupon_code
    @coupon_code ||= CouponCode.find_by(code: coupon_code_string)
  end

  def coupon_code_applies_to?(expense_item)
    coupon_code.coupon_code_expense_items.map(&:expense_item).include?(expense_item)
  end

  def coupon_limit_reached?
    coupon_code.max_uses_reached?
  end
end
