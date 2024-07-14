# Record when a user has opted out of Mass Emails
class MailOptOut < ApplicationRecord
  before_validation :set_opt_out_code

  validates :opt_out_code, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.opted_out?(email)
    find_by(email: email.downcase)&.opted_out?
  end

  # Create and return a new record, or find
  # existing record
  def self.create_if_not_present(email)
    existing = find_by(email: email.downcase)
    return existing if existing.present?

    create(email: email.downcase)
  end

  private

  def set_opt_out_code
    return if opt_out_code.present?

    self.opt_out_code = SecureRandom.alphanumeric(40).downcase
  end
end
