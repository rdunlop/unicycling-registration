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

  it "can determine the last online registration period" do
    RegistrationPeriod.last_online_period.should == @rp
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

    it "disregards onsite registration periods for last_online_period" do
      @rp.onsite = true
      @rp.save!
      RegistrationPeriod.last_online_period.should == @rp2
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
describe "when testing the update function for registration periods", :caching => true do
  before(:each) do
    # create a rp which encompasses "today"
    @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 12, 21), :end_date => Date.new(2020,11, 7))
    @reg = FactoryGirl.create(:competitor) # will have rp1
    @nc_reg = FactoryGirl.create(:noncompetitor) # will have rp1
  end
  it "initially doesn't have a current_period" do
    RegistrationPeriod.current_period.should == nil
  end
  it "initially says that no update has been (yet) performed" do
    RegistrationPeriod.update_checked_recently.should == false
  end

  it "initially, the registrant has an expense_item from the current period" do
    @reg.registrant_expense_items.count.should == 1
    @reg.registrant_expense_items.first.expense_item.should == @rp1.competitor_expense_item
    @nc_reg.registrant_expense_items.count.should == 1
    @nc_reg.registrant_expense_items.first.expense_item.should == @rp1.noncompetitor_expense_item
  end

  describe "after the update has been called" do
    before(:each) do
      ActionMailer::Base.deliveries.clear
      RegistrationPeriod.update_current_period(Date.new(2012, 12, 22))
    end
    it "sets the current period when invoked" do
      RegistrationPeriod.current_period.should == @rp1
    end

    it "says that an update has been performed recently" do
      RegistrationPeriod.update_checked_recently(Date.new(2012,12,22)).should == true
    end

    it "(when looking 3 days in the future) says that an update has not yet been done" do
      RegistrationPeriod.update_checked_recently(Date.new(2012,12,25)).should == false
    end

    it "sends an e-mail when it changes the reg period" do
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
    end

    describe "when updating to the next period" do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2020,11, 8), :end_date => Date.new(2021, 1, 1))
        @ret = RegistrationPeriod.update_current_period(Date.new(2020,12,1))
      end

      it "it indicates that the new period has been recently updated" do
        RegistrationPeriod.update_checked_recently(Date.new(2020,12,2)).should == true
      end
      it "indicates that it updated" do
        @ret.should == true
      end
      it "updates the current_period" do
        RegistrationPeriod.current_period.should == @rp2
      end
      it "sends an e-mail when it changes the reg period" do
        num_deliveries = ActionMailer::Base.deliveries.size
        num_deliveries.should == 1
        email = ActionMailer::Base.deliveries.first
        email.subject.should == "Updated Registration Period"
      end
      it "changes the registrant's item to the new period" do
        @reg.reload
        @reg.registrant_expense_items.count.should == 1
        @reg.registrant_expense_items.first.expense_item.should == @rp2.competitor_expense_item

        @nc_reg.reload
        @nc_reg.registrant_expense_items.count.should == 1
        @nc_reg.registrant_expense_items.first.expense_item.should == @rp2.noncompetitor_expense_item
      end
    end
    describe "when updating to a non-existent period" do
      before(:each) do
        ActionMailer::Base.deliveries.clear
        @ret = RegistrationPeriod.update_current_period(Date.new(2020,12,1))
      end

      it "indicates that it updated" do
        @ret.should == true
      end
      it "updates the current_period (which is nil)" do
        RegistrationPeriod.current_period.should == nil
      end
      it "sends an e-mail when it changes the reg period" do
        num_deliveries = ActionMailer::Base.deliveries.size
        num_deliveries.should == 1
        email = ActionMailer::Base.deliveries.first
        email.subject.should == "Updated Registration Period"
      end
      it "changes the registrant's item to the new period" do
        @reg.reload
        @reg.registrant_expense_items.count.should == 0

        @nc_reg.reload
        @nc_reg.registrant_expense_items.count.should == 0
      end
      describe "when updating to a now-existent period" do
        before(:each) do
          ActionMailer::Base.deliveries.clear
          @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2020,11, 8), :end_date => Date.new(2021, 1, 1))
          @ret = RegistrationPeriod.update_current_period(Date.new(2020,12,1))
        end

        it "indicates that it updated" do
          @ret.should == true
        end
        it "updates the current_period" do
          RegistrationPeriod.current_period.should == @rp2
        end
        it "sends an e-mail when it changes the reg period" do
          num_deliveries = ActionMailer::Base.deliveries.size
          num_deliveries.should == 2
          email = ActionMailer::Base.deliveries.first
          email.subject.should == "Updated Registration Period"
        end
        it "sends an e-mail for the registrant which didn't have a previous period entry" do
          email = ActionMailer::Base.deliveries.last
          email.subject.should == "Registration Items Missing!"
        end
        it "changes the registrant's item to the new period" do
          @reg.reload
          @reg.registrant_expense_items.count.should == 1
          @reg.registrant_expense_items.first.expense_item.should == @rp2.competitor_expense_item

          @nc_reg.reload
          @nc_reg.registrant_expense_items.count.should == 1
          @nc_reg.registrant_expense_items.first.expense_item.should == @rp2.noncompetitor_expense_item
        end
      end
    end
  end
end
