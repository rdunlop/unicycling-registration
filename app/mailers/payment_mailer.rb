class PaymentMailer < TenantAwareMailer
  # contents is a string
  def ipn_received(contents)
    @contents = contents

    mail to: Rails.application.secrets.error_emails
  end

  def payment_completed(payment)
    @payment_number = payment.id
    @total_amount = payment.total_amount
    @event_name = EventConfiguration.singleton.long_name

    mail to: payment.user.email, bcc: Rails.application.secrets.payment_notice_email
  end

  def coupon_used(payment_detail)
    @coupon = payment_detail.payment_detail_coupon_code.coupon_code
    @registrant = payment_detail.registrant
    @payment_id = payment_detail.payment_id

    mail to: @coupon.inform_emails, bcc: Rails.application.secrets.payment_notice_email
  end

  ######### ADMIN
  def missing_matching_expense_item(payment_id)
    @payment_id = payment_id

    mail to: Rails.application.secrets.error_emails, subject: "Missing reg-item match"
  end
end
