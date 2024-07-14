# Allows filtering out emails which have
# chosen to opt out of receiving email
module EmailFilterOptOut
  extend ActiveSupport::Concern

  def allowed_emails(all_emails)
    all_emails.reject do |email|
      MailOptOut.opted_out?(email)
    end
  end
end
