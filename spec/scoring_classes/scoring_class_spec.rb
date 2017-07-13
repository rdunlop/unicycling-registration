require 'spec_helper'

describe ScoringClass do
  describe "scoring_helpers" do
    Competition.scoring_classes.each do |scoring_class|
      let(:competition) { FactoryGirl.build(:competition, scoring_class: scoring_class) }
      it "has valid scoring_helper for #{scoring_class}" do
        scoring_helper = ScoringClass.for(scoring_class, competition)[:helper]
        expect(scoring_helper).not_to be_nil
      end
    end
  end
end
