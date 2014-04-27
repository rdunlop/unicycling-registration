require 'spec_helper'

def build_competitor(overall_place)
  comp = FactoryGirl.build_stubbed(:event_competitor)
  allow(comp).to receive(:overall_place).and_return(overall_place)
  allow(comp).to receive(:has_result?).and_return(true)
  allow(comp).to receive(:gender).and_return("Male")
  comp
end

describe CombinedCompetitionEntry do
  let(:combined_competition_entry) { FactoryGirl.build_stubbed(:combined_competition_entry) }
  it "is initially valid" do
    expect(combined_competition_entry).to be_valid
  end

  describe "when displaying the relevant associated competitors" do
    before :each do
      competition = FactoryGirl.build_stubbed(:competition)
      allow(combined_competition_entry).to receive(:competition).and_return(competition)

      @comp1 = build_competitor(1)
      @comp2 = build_competitor(2)
      @comp3 = build_competitor(3)
      @comp11 = build_competitor(11)
      @comp_unk = build_competitor(0)

      allow(competition).to receive(:competitors).and_return([@comp1, @comp2, @comp3, @comp11, @comp_unk])
    end

    it "lists the competitors who have ranked top 10" do
      expect(combined_competition_entry.competitors).to eq([[@comp1, @comp2, @comp3], []])
    end
  end
end
