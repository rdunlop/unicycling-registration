class VolunteerMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def new_volunteer(volunteer_choice_id)
    volunteer_choice =  VolunteerChoice.find(volunteer_choice_id)
    @registrant = volunteer_choice.registrant
    @volunteer_opportunity = volunteer_choice.volunteer_opportunity

    mail to: volunteer_choice.volunteer_opportunity.inform_emails, subject: "New Volunteer Signed Up"
  end
end
