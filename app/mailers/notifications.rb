class Notifications < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def ipn_received(contents)
    @contents = contents

    mail to: ENV['ERROR_EMAIL']
  end

  def payment_completed(payment)
    @payment_number = payment.id
    @total_amount = payment.total_amount
    @event_name = EventConfiguration.long_name

    mail to: payment.user.email, bcc: ENV['PAYMENT_NOTICE_EMAIL']
  end

  def send_feedback(form_details)
    @contact_form = form_details

    mail to: ENV['ERROR_EMAIL'], subject: 'Feedback'
  end
end
