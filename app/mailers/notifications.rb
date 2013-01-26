class Notifications < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.ipn_received.subject
  #
  def ipn_received(contents)
    @contents = contents

    mail to: "robin@dunlopweb.com"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.payment_completed.subject
  #
  def payment_completed(payment)
    @payment_number = payment.id

    mail to: "robin@dunlopweb.com"
  end
end
