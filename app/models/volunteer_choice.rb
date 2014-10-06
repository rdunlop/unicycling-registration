# == Schema Information
#
# Table name: volunteer_choices
#
#  id                       :integer          not null, primary key
#  registrant_id            :integer
#  volunteer_opportunity_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#
# Indexes
#
#  index_volunteer_choices_on_registrant_id             (registrant_id)
#  index_volunteer_choices_on_volunteer_opportunity_id  (volunteer_opportunity_id)
#  volunteer_choices_reg_vol_opt_unique                 (registrant_id,volunteer_opportunity_id) UNIQUE
#

class VolunteerChoice < ActiveRecord::Base

  belongs_to :volunteer_opportunity
  belongs_to :registrant

  after_create :send_email_to_admins

  def send_email_to_admins
    if volunteer_opportunity.inform_emails.present?
      VolunteerMailer.new_volunteer(self).deliver
    end
  end

end
