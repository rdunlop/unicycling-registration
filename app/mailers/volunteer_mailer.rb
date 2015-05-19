class VolunteerMailer < TenantAwareMailer
  def new_volunteer(volunteer_choice)
    @registrant = volunteer_choice.registrant
    @volunteer_opportunity = volunteer_choice.volunteer_opportunity

    mail to: volunteer_choice.volunteer_opportunity.inform_emails, subject: "New Volunteer Signed Up"
  end
end
