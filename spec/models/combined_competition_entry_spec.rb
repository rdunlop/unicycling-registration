require 'spec_helper'

describe CombinedCompetitionEntry do
  let(:combined_competition_entry) { FactoryGirl.build_stubbed(:combined_competition_entry) }
  it "is initially valid" do
    expect(combined_competition_entry).to be_valid
  end
end
