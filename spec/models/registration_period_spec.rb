require 'spec_helper'

describe RegistrationPeriod do
  before(:each) do
    @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 11,03), :end_date => Date.new(2012,11,07))
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

  it "must have onsite set" do
    @rp.onsite = nil
    @rp.valid?.should == false
  end

  it "is not onsite by default" do
    rp = RegistrationPeriod.new
    rp.onsite.should == false
  end

  it "calculates the closed_date as the day of the end date" do
    RegistrationPeriod.closed_date.should == Date.new(2012, 11,07)
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

    it "returns the first registration period INCLUDING the day AFTER the period ends" do
      RegistrationPeriod.relevant_period(Date.new(2012,02,03)).should == @rp1
    end

    it "returns the second registration period +2 days after the first period ends" do
      RegistrationPeriod.relevant_period(Date.new(2012,02,04)).should == @rp2
    end

    it "disregards onsite registration periods for closed_date" do
      @rp.onsite = true
      @rp.save!
      RegistrationPeriod.closed_date.should == Date.new(2012, 04, 04)
    end
    describe "with more registration periods" do
      before(:each) do
        @rp0 = FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 02, 03), :end_date => Date.new(2010,04,04))
      end
      it "returns the periods in ascending date order" do
        RegistrationPeriod.all.should == [@rp0, @rp1, @rp2, @rp]
      end
    end

    describe "when searching for a paid-for registration period" do
      it "can retrieve the matching registration_period" do
        RegistrationPeriod.paid_for_period(true, []).should == nil
      end
      it "can retrieve a matching competitor period" do
        RegistrationPeriod.paid_for_period(true, [@rp1.competitor_expense_item]).should == @rp1
        RegistrationPeriod.paid_for_period(true, [@rp2.competitor_expense_item]).should == @rp2
      end
      it "can retrieve a matching noncompetitor period" do
        RegistrationPeriod.paid_for_period(false, [@rp1.noncompetitor_expense_item]).should == @rp1
        RegistrationPeriod.paid_for_period(false, [@rp2.noncompetitor_expense_item]).should == @rp2
      end
    end

    it "can identify the current period" do
      @rp1.current_period?(Date.new(2012,01,14)).should == true
      @rp2.current_period?(Date.new(2012,01,14)).should == false
    end
    it "can identify past periods" do
      @rp1.past_period?(Date.new(2012,02,20)).should == true
      @rp2.past_period?(Date.new(2012,02,20)).should == false
    end
  end
end
