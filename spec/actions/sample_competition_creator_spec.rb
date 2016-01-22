require 'spec_helper'

describe SampleCompetitionCreator do
  before do
    # need at least 1 event to create the competitions against
    FactoryGirl.create(:event)
  end

  Competition.scoring_classes.each do |scoring_class|
    next if scoring_class == "Overall Champion"
    it "can create #{scoring_class} competition type" do
      expect do
        result = described_class.new(scoring_class).create
        expect(result).to be_truthy
      end.to change(Competition, :count).by(1)
    end
  end
end
