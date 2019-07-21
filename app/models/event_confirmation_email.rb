# == Schema Information
#
# Table name: event_confirmation_emails
#
#  id               :bigint           not null, primary key
#  sent_by_id       :integer
#  reply_to_address :string
#  subject          :string
#  body             :text
#  sent_at          :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class EventConfirmationEmail < ApplicationRecord
  belongs_to :sent_by, class_name: "User"

  validates :sent_by, presence: true, if: :sent_at
  validates :subject, :body, presence: true
  validate :all_templates_are_known

  def sent?
    !sent_at.nil?
  end

  def send!(user)
    return false if sent?

    self.sent_by = user
    self.sent_at = Time.current
    saved = save
    EventConfirmationEmailSenderJob.perform_later(self) if saved

    saved
  end

  def subject_result(registrant)
    RegistrantTemplateParser.new(registrant, subject).result
  end

  def body_result(registrant)
    RegistrantTemplateParser.new(registrant, body).result
  end

  def email_addresses(registrant)
    [registrant.user.email, registrant.email].compact.uniq
  end

  private

  def all_templates_are_known
    unless RegistrantTemplateParser.new(Registrant.competitor.sample, subject).valid?
      errors.add(:subject, "Invalid Template specified")
    end
    unless RegistrantTemplateParser.new(Registrant.competitor.sample, body).valid?
      errors.add(:body, "Invalid Template specified")
    end
  end
end
