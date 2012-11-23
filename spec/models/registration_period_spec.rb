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

  describe "with existing periods" do
    before(:each) do
      @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 01, 01), :end_date => Date.new(2012,02,02), :competitor_cost => 100, :noncompetitor_cost => 50)
      @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 02, 03), :end_date => Date.new(2012,04,04), :competitor_cost => 200, :noncompetitor_cost => 75)
    end

    it "can retrieve period" do
      RegistrationPeriod.relevant_period(Date.new(2012,01,15)).should == @rp1
    end

    it "gets nil for missing section" do
      RegistrationPeriod.relevant_period(Date.new(2010,01,01)).should == nil
    end
  end
end
