require "spec_helper"

RSpec.describe CompetitorAgeGroupEntryUpdateJob do
  let(:competitor) { FactoryBot.create(:event_competitor, competition: competition) }

  describe "#perform" do
    subject(:job) { described_class.new(competitor.id) }

    context "with an age group existing" do
      let(:age_group_type) { FactoryBot.create(:age_group_type) }
      let!(:age_group_entry_male) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type) }
      let!(:age_group_entry_female) { FactoryBot.create(:age_group_entry, :female, age_group_type: age_group_type) }
      let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }

      it "sets the age group entry" do
        competitor.update_column(:age_group_entry_id, nil) # Clear out the id
        job.perform_now
        expect(competitor.reload.age_group_entry).not_to be_nil
      end
    end

    context "Without an age group" do
      let(:competition) { FactoryBot.create(:competition) }

      it "does nothing" do
        job.perform_now
        expect(competitor.age_group_entry).to be_nil
      end
    end

    context "with an age group, but without a matching entry" do
      let(:age_group_type) { FactoryBot.create(:age_group_type) }
      # NOTE: All factorybot registrants are male
      let!(:age_group_entry_female) { FactoryBot.create(:age_group_entry, :female, age_group_type: age_group_type) }
      let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }

      it "creates the warning message for the age group entry" do
        competitor.update_column(:age_group_entry_id, nil) # Clear out the id
        MissingAgeGroupEntryWarning.destroy_all
        job.perform_now
        expect(competitor.age_group_entry).to be_nil
        expect(MissingAgeGroupEntryWarning.count).to eq(1)
      end
    end
  end
end
