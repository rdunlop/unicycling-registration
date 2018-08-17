require 'spec_helper'

describe Importers::TierUpdater do
  let(:competition) { FactoryBot.create(:tier_competition) }

  describe "update waves" do
    let!(:competitor1) { FactoryBot.create(:event_competitor, competition: competition, bib_number: 101) }

    let(:processor) do
      double(
        valid_file?: true,
        file_contents: ["line"],
        process_row: {
          bib_number: "101",
          tier_number: "2",
          tier_description: "2 laps"
        }
      )
    end

    it "updates the waves" do
      expect(competitor1.wave).to be_nil

      expect(described_class.new(competition, nil).process(processor)).to be_truthy

      expect(competitor1.reload.tier_number).to eq(2)
      expect(competitor1.reload.tier_description).to eq("2 laps")
    end

    context "When searching for a bib_number which is not found" do
      before { competitor1.destroy }

      it "returns an error" do
        importer = described_class.new(competition, nil)
        expect(importer.process(processor)).to be_falsey
        expect(importer.errors).to eq("Unable to find competitor 101")
      end
    end
  end
end
