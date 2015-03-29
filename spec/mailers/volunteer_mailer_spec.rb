require "spec_helper"

describe VolunteerMailer do
  let(:volunteer_opportunity) { FactoryGirl.create(:volunteer_opportunity, inform_emails: inform_emails) }
  let(:volunteer_choice) { FactoryGirl.create(:volunteer_choice, volunteer_opportunity: volunteer_opportunity) }

  context "with multiple inform_emails" do
    let(:inform_emails) { "test@test.com, test2@test.com" }

    it "doesn't create an e-mail" do
      mail = described_class.new_volunteer(volunteer_choice)
      expect(mail.subject).to eq("New Volunteer Signed Up")
      expect(mail.to).to contain_exactly("test@test.com", "test2@test.com")
    end
  end
end
