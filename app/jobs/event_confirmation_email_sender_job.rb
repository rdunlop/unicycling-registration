# Send an e-mail to each individual competitor about their registration
class EventConfirmationEmailSenderJob < ApplicationJob
  def perform(event_confirmation_email)
    Registrant.active_or_incomplete.competitor.find_each do |registrant|
      Notifications.event_confirmation_email(
        event_confirmation_email.email_addresses(registrant),
        event_confirmation_email.reply_to_address,
        event_confirmation_email.subject_result(registrant),
        event_confirmation_email.body_result(registrant)
      ).deliver_later
    end
  end
end
