class VolunteerMailerPreview < ActionMailer::Preview
  def new_volunteer
    VolunteerMailer.new_volunteer(volunteer_choice)
  end

  private

  def volunteer_choice
    VolunteerChoice.all.sample
  end
end
