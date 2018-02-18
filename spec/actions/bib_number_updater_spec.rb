require 'spec_helper'

RSpec.describe BibNumberUpdater do
  INITIAL_NONCOMPETITOR_NUMBER = BibNumberFinder::FreeNumber.new("noncompetitor").range.first
  let!(:competitor1) { FactoryBot.create(:competitor) }
  let!(:competitor2) { FactoryBot.create(:competitor) }
  let!(:competitor3) { FactoryBot.create(:competitor) }

  let!(:noncompetitor1) { FactoryBot.create(:noncompetitor) }
  let!(:noncompetitor2) { FactoryBot.create(:noncompetitor) }
  let!(:noncompetitor3) { FactoryBot.create(:noncompetitor) }

  describe "#free_bib_number" do
    context "with a competitor" do
      it "changes the competitor's bib number" do
        old_bib_number = competitor1.bib_number
        expect do
          described_class.free_bib_number(competitor1.bib_number)
        end.to change { competitor1.reload.bib_number }
        expect(Registrant.find_by(bib_number: old_bib_number)).to be_nil
      end

      it "sets the bib number to a competitor-bib-number" do
        described_class.free_bib_number(competitor1.bib_number)
        expect(competitor1.reload.bib_number).to be < INITIAL_NONCOMPETITOR_NUMBER
      end

      context "with related event-competitors" do
        let!(:event_competitor) { FactoryBot.create(:event_competitor) }
        let!(:member) { FactoryBot.create(:member, competitor: event_competitor, registrant: competitor1) }

        it "touches the competitor" do
          expect do
            described_class.free_bib_number(competitor1.bib_number)
          end.to change { event_competitor.reload.updated_at }
        end
      end
    end

    context "with a non-competitor" do
      it "sets the non-competitor to a new non-competitor id" do
        described_class.free_bib_number(noncompetitor1.bib_number)
        expect(noncompetitor1.reload.bib_number).to be > INITIAL_NONCOMPETITOR_NUMBER
      end
    end
  end

  describe "#update_bib_number" do
    it "sets the registrant to the given bib number" do
      described_class.update_bib_number(competitor1, 2)
      expect(competitor1.reload.bib_number).to eq(2)
    end
  end

  describe "#valid_new_bib_number" do
    it "allows strings to be passed in" do
      expect(described_class.valid_new_bib_number(competitor1, "1")).to be_truthy
    end

    it "does not allow setting a bib_number outside the competitor range" do
      expect(described_class.valid_new_bib_number(competitor1, 10000)).to be_falsey
    end

    it "allows a competitor above the current max number" do
      expect(described_class.valid_new_bib_number(competitor1, competitor1.bib_number + 100)).to be_truthy
    end

    it "allows a competitor in normal range" do
      expect(described_class.valid_new_bib_number(competitor1, competitor1.bib_number + 1)).to be_truthy
    end

    it "disallows a noncompetitor in competitor range" do
      expect(described_class.valid_new_bib_number(noncompetitor1, 10)).to be_falsey
    end

    it "allows a noncompetitor in noncompetitor range" do
      expect(described_class.valid_new_bib_number(noncompetitor1, INITIAL_NONCOMPETITOR_NUMBER + 1)).to be_truthy
    end
  end
end
