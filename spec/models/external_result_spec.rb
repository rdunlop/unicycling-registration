require 'spec_helper'

describe ExternalResult do
  before(:each) do
    @er = FactoryGirl.create(:external_result)
  end
  it "has a valid factory" do
    @er.valid?.should == true
  end

  it "must have a competitor" do
    @er.competitor = nil
    @er.valid?.should == false
  end

  it "must have details" do
    @er.details = nil
    @er.valid?.should == false
  end

  it "must have a rank" do
    @er.rank = nil
    @er.valid?.should == false
  end
end
