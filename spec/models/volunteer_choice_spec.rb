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


require 'spec_helper'

describe VolunteerChoice do
  describe "creating a volunteer choice" do
    let(:volunteer_opportunity) { FactoryBot.create(:volunteer_opportunity) }
    let!(:registrant) { FactoryBot.create(:registrant) }

    let(:subject) { described_class.new(volunteer_opportunity: volunteer_opportunity, registrant: registrant) }

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
      end.to change(described_class, :count).by(1)
    end
  end
end
