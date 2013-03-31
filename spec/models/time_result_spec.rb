require 'spec_helper'

describe TimeResult do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
    @reg = FactoryGirl.create(:competitor)
    @tr = FactoryGirl.create(:time_result, :event_category => @ec, :registrant => @reg)
  end
  it "is valid from FactoryGirl" do
    @tr.valid?.should == true
  end

  it "requires an event_categroy" do
    @tr.event_category = nil
    @tr.valid?.should == false
  end

  it "requires a registrant" do
    @tr.registrant = nil
    @tr.valid?.should == false
  end

  it "requires a DQ value" do
    @tr.disqualified = nil
    @tr.valid?.should == false
  end

  it "cannot have a negative minutes value" do
    @tr.minutes = -1
    @tr.valid?.should == false
  end

  it "cannot have a negative seconds value" do
    @tr.seconds = -1
    @tr.valid?.should == false
  end

  it "cannot have a negative thousands value" do
    @tr.thousands = -1
    @tr.valid?.should == false
  end

  describe "With a new TimeResult" do
    subject { TimeResult.new }
    it "defaults to not DQ" do
      subject.disqualified.should == false
    end

    it "defaults to 0 minutes" do
      subject.minutes.should == 0
    end
    it "defaults to 0 seconds" do
      subject.seconds.should == 0
    end
    it "defaults to 0 thousands" do
      subject.thousands.should == 0
    end
  end

  it "refers to a registrant" do
    @tr.registrant.should == @reg
  end

  it "refers to an event_category" do
    @tr.event_category.should == @ec
  end

  it "Cannot have the same registrant have 2 results for the same event_category" do
    @tr = FactoryGirl.build(:time_result, :event_category => @ec, :registrant => @reg)
    @tr.valid?.should == false
  end

  it "can print the full time when all values exist" do
    @tr.minutes = 19
    @tr.seconds = 16
    @tr.thousands = 701
    @tr.full_time.should == "19:16:701"
  end

  it "can print the full time when the numbers start with 0" do
    @tr.minutes = 9
    @tr.seconds = 6
    @tr.thousands = 05
    @tr.full_time.should == "9:06:005"
  end

  it "can print the full time when the minutes are more than an hour" do
    @tr.minutes = 61
    @tr.seconds = 10
    @tr.thousands = 123

    @tr.full_time.should == "1:01:10:123"
  end

  it "can return the full time in thousands" do
    @tr.minutes = 1
    @tr.seconds = 2
    @tr.thousands = 3
    @tr.full_time_in_thousands.should == 62003
  end

  it "by default has nil place" do
    @tr.place.should == nil
  end

  it "can store the place" do
    @tr.place = 1
    @tr.place.should == 1
  end
end
