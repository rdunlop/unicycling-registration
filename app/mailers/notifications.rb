class Notifications < TenantAwareMailer
  def send_feedback(form_details)
    @contact_form = ContactForm.deserialize(form_details)
    mail to: EventConfiguration.singleton.contact_email.presence,
         reply_to: @contact_form.reply_to_email,
         cc: Rails.application.secrets.error_emails, subject: 'Feedback'
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

  def send_mass_email(email_yaml, addresses)
    email = Email.deserialize(email_yaml)
    @body = email.body

    mail bcc: addresses, subject: email.subject
  end

  ######### ADMIN
  def updated_current_reg_period(old_period_name, new_period_name)
    @old_period_description = old_period_name || "Unspecified"

    @new_period_description = new_period_name || "Unspecified"

    mail to: Rails.application.secrets.error_emails, subject: "Updated Registration Period"
  end

  def missing_old_reg_items(bib_numbers)
    @bib_numbers = bib_numbers

    mail to: Rails.application.secrets.error_emails, subject: "Registration Items Missing!"
  end
end
