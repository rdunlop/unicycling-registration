class Notifications < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.ipn_received.subject
  #
  def ipn_received(contents)
    # XXX this action should be disabled soon.
    @contents = contents

    mail to: ENV['ERROR_EMAIL']
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.payment_completed.subject
  #
  def payment_completed(payment)
    @payment_number = payment.id
    @total_amount = payment.total_amount
    @event_name = EventConfiguration.long_name

    mail to: payment.user.email, bcc: ENV['PAYMENT_NOTICE_EMAIL']
  end

  def send_feedback(feedback)
    @feedback = feedback

    mail to: ENV['ERROR_EMAIL'], subject: 'Feedback'
  end
end
