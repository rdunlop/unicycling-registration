require 'spec_helper'

RSpec.describe BibNumberUpdater do
  let!(:competitor1) { FactoryGirl.create(:competitor) }
  let!(:competitor2) { FactoryGirl.create(:competitor) }
  let!(:competitor3) { FactoryGirl.create(:competitor) }

  let!(:noncompetitor1) { FactoryGirl.create(:noncompetitor) }
  let!(:noncompetitor2) { FactoryGirl.create(:noncompetitor) }
  let!(:noncompetitor3) { FactoryGirl.create(:noncompetitor) }

  describe "#duplicates" do
    before do
      competitor2.update(bib_number: competitor1.bib_number)
    end

    it "finds the duplicate" do
      expect(described_class.duplicates).to eq([competitor1.bib_number])
    end
  end

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
        expect(competitor1.reload.bib_number).to be <= RegistrantType::Noncompetitor::INITIAL
      end

      context "with related event-competitors" do
        let!(:event_competitor) { FactoryGirl.create(:event_competitor) }
        let!(:member) { FactoryGirl.create(:member, competitor: event_competitor, registrant: competitor1) }

        it "touches the competitor" do
          expect do
            described_class.free_bib_number(competitor1.bib_number)
          end.to change{ event_competitor.reload.updated_at }
        end
      end
    end

    context "with a non-competitor" do
      it "sets the non-competitor to a new non-competitor id" do
        described_class.free_bib_number(noncompetitor1.bib_number)
        expect(noncompetitor1.reload.bib_number).to be > RegistrantType::Noncompetitor::INITIAL
      end
    end
  end

  describe "#update_bib_number" do
    it "sets the registrant to the given bib number" do
      described_class.update_bib_number(competitor1, 2)
      expect(competitor1.reload.bib_number).to eq(2)
    end
  end
end
