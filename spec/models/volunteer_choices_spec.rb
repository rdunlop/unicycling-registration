require 'spec_helper'

describe VolunteerChoice do
  describe "creating a volunteer choice" do
    let(:volunteer_opportunity) { FactoryGirl.create(:volunteer_opportunity) }
    let!(:registrant) { FactoryGirl.create(:registrant) }

    let(:subject) {  VolunteerChoice.new(volunteer_opportunity: volunteer_opportunity, registrant: registrant) }

    before { ActionMailer::Base.deliveries.clear }

    it "sends an e-mail if one is defined" do
      subject.save
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "doesn't send e-mail if no one is defined as target" do
      volunteer_opportunity.update_attribute(:inform_emails, nil)
      subject.save
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end

    specify do
      expect do
        subject.save
      end.to change(VolunteerChoice, :count).by(1)
    end
  end
end
