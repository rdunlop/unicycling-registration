require "spec_helper"

RSpec.describe CompetitorAgeGroupEntryUpdateJob do
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition) }

  describe "#perform" do
    subject(:job) { described_class.new(competitor.id) }

    context "with an age group existing" do
      let(:age_group_type) { FactoryGirl.create(:age_group_type) }
      let!(:age_group_entry_male) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }
      let!(:age_group_entry_female) { FactoryGirl.create(:age_group_entry, :female, age_group_type: age_group_type) }
      let(:competition) { FactoryGirl.create(:timed_competition, age_group_type: age_group_type) }
      let(:age) { create :order, :completed }

      it "sets the age group entry" do
        expect(competitor.age_group_entry).not_to be_nil
      end
    end

    context "Without an age group" do
      let(:competition) { FactoryGirl.create(:competition) }

      it "does nothing" do
        job.perform_now
        expect(competitor.age_group_entry).to be_nil
      end
    end
  end
end
