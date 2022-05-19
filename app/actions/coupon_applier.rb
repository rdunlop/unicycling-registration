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

    if applied_count.zero?
      self.error ||= "Coupon Code not applicable to this order"
    end

    self.error.nil?
  end

  private

  def apply_coupon(payment_detail)
    return unless coupon_code_applies_to_line_item?(payment_detail.line_item)
    return unless coupon_code_applies_to_registrant_age?(payment_detail.registrant.age)

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

  def coupon_code_applies_to_line_item?(line_item)
    # Need to adjust this to allow the line_item to determine whether the coupon_code applies to it
    # so that we can specify a coupon code which applies to a LodgingRoomOption, while the line_item is a
    # LodgingPackage
    coupon_code.coupon_code_expense_items.map(&:line_item).any? do |coupon_line_item|
      line_item.valid_coupon?(coupon_line_item)
    end
  end

  def coupon_code_applies_to_registrant_age?(age)
    return true unless coupon_code.maximum_registrant_age?

    age <= coupon_code.maximum_registrant_age
  end

  def coupon_limit_reached?
    coupon_code.max_uses_reached?
  end
end
