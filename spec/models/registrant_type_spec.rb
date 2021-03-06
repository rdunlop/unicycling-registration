require 'spec_helper'

describe RegistrantType do
  context "as a competitor" do
    subject(:registrant_type) { described_class.for("competitor") }

    it "initially assigns 1" do
      expect(subject.next_available_bib_number).to eq(1)
    end

    describe "with a second competitor" do
      before do
        FactoryBot.create(:competitor)
      end

      it "assigns the second competitor bib_number 2" do
        expect(subject.next_available_bib_number).to eq(2)
      end
    end
  end

  context "as a noncompetitor" do
    subject(:registrant_type) { described_class.for("noncompetitor") }

    it "initially assigns 2001" do
      expect(subject.next_available_bib_number).to eq(2001)
    end

    describe "with a second noncompetitor" do
      before do
        FactoryBot.create(:noncompetitor)
      end

      it "assigns the second noncompetitor bib_number 2002" do
        expect(subject.next_available_bib_number).to eq(2002)
      end
    end
  end
end
