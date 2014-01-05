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

  ######### ADMIN
  def missing_matching_expense_item(payment)
    @payment = payment

    mail to: ENV['ERROR_EMAIL'], subject: "Missing reg-item match"
  end

  def updated_current_reg_period(old_period, new_period)
    @old_period_description = "Unspecified"
    @old_period_description = old_period.name unless old_period.nil?

    @new_period_description = "Unspecified"
    @new_period_description = new_period.name unless new_period.nil?

    mail to: ENV['ERROR_EMAIL'], subject: "Updated Registration Period"
  end

  def missing_old_reg_items(bib_numbers)
    @bib_numbers = bib_numbers

    mail to: ENV['ERROR_EMAIL'], subject: "Registration Items Missing!"
  end
end
