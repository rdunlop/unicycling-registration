class NotificationsPreview < ActionMailer::Preview
  def send_feedback
    Notifications.send_feedback(contact_form.serialize)
  end

  def request_registrant_access
    Notifications.request_registrant_access(registrant, user)
  end

  def registrant_access_accepted
    Notifications.registrant_access_accepted(registrant, user)
  end

  def send_mass_email
    Notifications.send_mass_email(email.serialize, addresses)
  end

  ######### ADMIN
  def updated_current_reg_period
    Notifications.updated_current_reg_period("Early Registration", "Late Registration")
  end

  def missing_old_reg_items
    bib_numbers = [1, 2, 3]
    Notifications.missing_old_reg_items(bib_numbers)
  end

  private

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

  def addresses
    ["robin+test@dunlopeb.com", "robin+test2@dunlopweb.com"]
  end
end
