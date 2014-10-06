class NotificationsPreview < ActionMailer::Preview

  def ipn_received
    contents = "IPN says"
    Notifications.ipn_received(contents)
  end

  def payment_completed
    Notifications.payment_completed(payment)
  end

  def send_feedback
    Notifications.send_feedback(contact_form)
  end

  def request_registrant_access
    Notifications.request_registrant_access(registrant, user)
  end

  def registrant_access_accepted
    NotificatinosMailer.registrant_access_accepted(registrant, user)
  end

  def send_mass_email
    Notifications.send_mass_email(email, addresses)
  end

  ######### ADMIN
  def missing_matching_expense_item
    Notifications.missing_matching_expense_item(payment)
  end

  def updated_current_reg_period
    Notifications.updated_current_reg_period(old_period, new_period)
  end

  def missing_old_reg_items
    bib_numbers = "1,2,3"
    Notifications.missing_old_reg_items(bib_numbers)
  end

  private

  def payment
    Payment.all.sample
  end

  def contact_form
    ContactForm.new(feedback: "This is a great site", email: "big_shot@unicycling.org", signed_in: false)
  end

  def registrant
    Registrant.all.sample
  end

  def user
    User.all.sample
  end

  def email
    Email.new(body: "This is a mass e-mail body", subject: "I want to inform all of you")
  end

  def old_period
    RegistrationPeriod.new(name: "Early Registration")
  end

  def new_period
    RegistrationPeriod.new(name: "Late Registration")
  end
end
