require 'spec_helper'

describe VolunteerChoice do
  describe "creating a volunteer choice" do
    let(:volunteer_opportunity) { FactoryGirl.create(:volunteer_opportunity) }
    let(:registrant) { FactoryGirl.create(:registrant) }

    let(:subject) {  VolunteerChoice.new(volunteer_opportunity: volunteer_opportunity, registrant: registrant) }

    it "sends an e-mail if one is defined" do
      expect(VolunteerMailer).to receive_message_chain(:new_volunteer, :deliver)
      subject.save
    end

    it "doesn't send e-mail if no one is defined as target" do
      expect(VolunteerMailer).not_to receive(:new_volunteer)
      volunteer_opportunity.update_attribute(:inform_emails, nil)
      subject.save
    end

    specify do
      expect {
        subject.save
      }.to change(VolunteerChoice, :count).by(1)
    end
  end
end
