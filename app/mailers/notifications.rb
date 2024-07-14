class Notifications < TenantAwareMailer
  def send_feedback(feedback_id)
    @feedback = Feedback.find(feedback_id)
    mail to: EventConfiguration.singleton.contact_email.presence,
         reply_to: @feedback.reply_to_email,
         cc: Rails.configuration.error_emails, subject: "Feedback: #{@feedback.subject}"
  end

  def request_registrant_access(target_registrant, requesting_user)
    @target_registration = target_registrant.to_s
    @requesting_user_email = requesting_user.email

    mail to: target_registrant.user.email, subject: 'Requesting access to your Registration'
  end

  def registrant_access_accepted(target_registrant, requesting_user)
    @target_registration = target_registrant.to_s

    mail to: requesting_user.email, subject: 'Registration Access Granted'
  end

  def send_mass_email(subject, body, addresses, opt_out_code)
    @body = body
    @opt_out_code = opt_out_code

    mail bcc: addresses, subject: subject, reply_to: EventConfiguration.singleton.contact_email
  end

  def event_confirmation_email(to_addresses, reply_to, subject, body)
    @body = body

    mail to: to_addresses, subject: subject, reply_to: reply_to
  end

  ######### ADMIN
  def updated_current_reg_period(old_period_name, new_period_name)
    @old_period_description = old_period_name || "Unspecified"

    @new_period_description = new_period_name || "Unspecified"

    @convention_name = EventConfiguration.singleton.long_name

    mail to: Rails.configuration.error_emails, subject: "Updated Registration Period"
  end

  def missing_old_reg_items(bib_numbers)
    @bib_numbers = bib_numbers

    mail to: Rails.configuration.error_emails, subject: "Registration Items Missing!"
  end

  def certificate_renewal_command_status(command, stdout_lines, stderr_lines, success)
    @command = command
    @stdout_lines = stdout_lines
    @stderr_lines = stderr_lines
    @success = success

    mail to: Rails.configuration.server_admin_email, subject: "Certificates Renewed [#{Rails.env}]"
  end

  def new_convention_created(convention_name, subdomain)
    @convention_name = convention_name
    @subdomain = subdomain
    mail to: Rails.configuration.server_admin_email, subject: "New Convention Created #{convention_name}"
  end

  def old_password_used(user, subdomain)
    @email = user
    @subdomain = subdomain
    mail to: Rails.configuration.server_admin_email, subject: "User used old password to log in"
  end
end
