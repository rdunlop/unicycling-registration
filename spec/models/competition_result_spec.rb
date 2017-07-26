require 'spec_helper'

describe CompetitionResult do
  let(:competition) { FactoryGirl.create(:competition) }

  let(:competition_result) { FactoryGirl.build(:competition_result) }

  it "is valid from FactoryGirl" do
    expect(competition_result).to be_valid
  end

  context "with a custom name" do
    let(:competition_result) { FactoryGirl.build(:competition_result, system_managed: true, name: "Fun Results") }

    it "has a title of 'Fun Results'" do
      expect(competition_result.to_s).to eq("Fun Results")
    end
  end

  context "as system managed without a custom name" do
    let(:competition_result) { FactoryGirl.build(:competition_result, system_managed: true, name: nil) }

    it "has a title of 'Results'" do
      expect(competition_result.to_s).to eq("Results")
    end
  end
end
