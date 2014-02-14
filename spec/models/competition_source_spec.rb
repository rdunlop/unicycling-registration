require 'spec_helper'

describe CompetitionSource do
  before(:each) do
    @competition = FactoryGirl.create(:competition)
    @cs = FactoryGirl.create(:competition_source, :target_competition => @competition)
  end
  it "is valid from FactoryGirl" do
    @cs.valid?.should == true
  end

  it "requires a gender_filter" do
    @cs.gender_filter = nil
    @cs.valid?.should == false
  end
  it "requires an target_competition" do
    @cs.target_competition = nil
    @cs.valid?.should == false
  end

  it "requires a competition or event_category" do
    @cs.event_category = nil
    @cs.competition = nil
    @cs.valid?.should == false
  end

  it "can be found from the competition" do
    @competition.competition_sources.should == [@cs]
  end
end
