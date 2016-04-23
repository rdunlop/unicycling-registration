class ManualPaymentReceiver
  def self.send_emails(payment)
    users = payment.payment_details.map(&:registrant).map(&:user).flatten.uniq
    users.each do |user|
      PaymentMailer.manual_payment_completed(payment, user).deliver_later
    end
  end
end
