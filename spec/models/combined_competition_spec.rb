require 'spec_helper'

describe CombinedCompetition do
  let(:combined_competition) { FactoryGirl.build_stubbed(:combined_competition) }

  it "requires a name" do
    expect(combined_competition).to be_valid
  end
end
