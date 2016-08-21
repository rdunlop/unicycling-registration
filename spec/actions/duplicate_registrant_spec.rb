require 'spec_helper'

describe DuplicateRegistrant do
  let(:action) { described_class.new(registrant) }

  context "With a competitor" do
    let(:registrant) { FactoryGirl.create(:competitor) }

    it "creates a new noncompetitor" do
      expect{ action.to_noncompetitor }.to change(Registrant.noncompetitor, :count)
    end
  end

  context "With a noncompetitor" do
    let(:registrant) { FactoryGirl.create(:noncompetitor) }

    it "creates a new noncompetitor" do
      expect{ action.to_competitor }.to change(Registrant.competitor, :count)
    end
  end

  context "with a registrant without a contact_detail" do
    context "With a noncompetitor" do
      let(:registrant) { FactoryGirl.create(:noncompetitor, contact_detail: nil) }

      it "creates a new noncompetitor" do
        expect{ action.to_competitor }.to change(Registrant.competitor, :count)
      end
    end
  end
end
