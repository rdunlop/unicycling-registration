require 'spec_helper'

describe Importers::WaveUpdater do
  let(:competition) { FactoryGirl.create(:timed_competition) }

  describe "update waves" do
    let!(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 101) }

    let(:processor) do
      double(
        valid_file?: true,
        file_contents: ["line"],
        process_row: {
          bib_number: "101",
          wave: "1"
        }
      )
    end

    it "updates the waves" do
      expect(competitor1.wave).to be_nil

      expect(described_class.new(competition, nil).process(processor)).to be_truthy

      expect(competitor1.reload.wave).to eq(1)
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
