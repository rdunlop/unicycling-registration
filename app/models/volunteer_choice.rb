# == Schema Information
#
# Table name: volunteer_choices
#
#  id                       :integer          not null, primary key
#  registrant_id            :integer          not null
#  volunteer_opportunity_id :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#
# Indexes
#
#  index_volunteer_choices_on_registrant_id             (registrant_id)
#  index_volunteer_choices_on_volunteer_opportunity_id  (volunteer_opportunity_id)
#  volunteer_choices_reg_vol_opt_unique                 (registrant_id,volunteer_opportunity_id) UNIQUE
#

class VolunteerChoice < ApplicationRecord
  belongs_to :volunteer_opportunity
  belongs_to :registrant, inverse_of: :volunteer_choices

  validates :registrant_id, :volunteer_opportunity_id, presence: true
  validates :registrant_id, uniqueness: { scope: [:volunteer_opportunity_id] }

  after_create :send_email_to_admins

  delegate :to_s, to: :volunteer_opportunity

  private

  def send_email_to_admins
    if volunteer_opportunity.inform_emails.present?
      # Wait a minute to deliver so that the VolunteerChoice has been created
      # before attempting to e-mail
      VolunteerMailer.new_volunteer(self).deliver_later(wait: 1.minute)
    end
  end
end
