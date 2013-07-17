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

  def request_registrant_access(target_registrant, requesting_user)

    @target_registration = target_registrant.to_s
    @requesting_user_email = requesting_user.email

    mail to: target_registrant.user.email, subject: 'Requesting access to your Registration'
  end

  def registrant_access_accepted(target_registrant, requesting_user)
    @target_registration = target_registrant.to_s

    mail to: requesting_user.email, subject: 'Registrantion Access Granted'
  end

  def send_mass_email(email, addresses)
    @body = email.body

    mail bcc: addresses, subject: email.subject
  end
end
