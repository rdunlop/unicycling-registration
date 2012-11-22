require 'spec_helper'

describe RegistrationPeriod do
  before(:each) do
    @rp = FactoryGirl.create(:registration_period)
  end

  it "is valid from FactoryGirl" do
    @rp.valid?.should == true
  end

  it "must have a start date" do
    @rp.start_date = nil
    @rp.valid?.should == false
  end

  it "must have an end date" do
    @rp.end_date = nil
    @rp.valid?.should == false
  end

  it "must have a competitor cost" do
    @rp.competitor_cost = nil
    @rp.valid?.should == false
  end

  it "must have a noncompetitor cost" do
    @rp.noncompetitor_cost = nil
    @rp.valid?.should == false
  end
end
