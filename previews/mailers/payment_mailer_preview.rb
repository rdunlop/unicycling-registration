class PaymentMailerPreview < ActionMailer::Preview
  def ipn_received
    contents = "IPN says"
    PaymentMailer.ipn_received(contents)
  end

  def payment_completed
    PaymentMailer.payment_completed(payment)
  end

  def manual_payment_completed
    PaymentMailer.manual_payment_completed(payment, user)
  end

  def coupon_used
    PaymentMailer.coupon_used(payment_detail)
  end

  ######### ADMIN
  def missing_matching_expense_item
    PaymentMailer.missing_matching_expense_item(payment.id)
  end

  private

  def payment
    Payment.all.sample
  end

  def payment_detail
    PaymentDetailCouponCode.first.payment_detail
  end

  def user
    User.all.sample
  end
end
