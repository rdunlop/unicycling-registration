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

  it "must have a competitor_expense_item" do
    @rp.competitor_expense_item = nil
    @rp.valid?.should == false
  end

  it "must have a noncompetitor_expense_item" do
    @rp.noncompetitor_expense_item = nil
    @rp.valid?.should == false
  end

  describe "with existing periods" do
    before(:each) do
      @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 01, 01), :end_date => Date.new(2012,02,02))
      @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 02, 03), :end_date => Date.new(2012,04,04))
    end

    it "can retrieve period" do
      RegistrationPeriod.relevant_period(Date.new(2012,01,15)).should == @rp1
    end

    it "gets nil for missing section" do
      RegistrationPeriod.relevant_period(Date.new(2010,01,01)).should == nil
    end
  end
end
