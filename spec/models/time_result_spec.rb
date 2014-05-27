# == Schema Information
#
# Table name: time_results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  minutes        :integer
#  seconds        :integer
#  thousands      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  is_start_time  :boolean          default(FALSE)
#  attempt_number :integer
#  status         :string(255)
#  comments       :text
#

require 'spec_helper'

describe TimeResult do
  before(:each) do
    @competitor = FactoryGirl.create(:event_competitor)
    @tr = FactoryGirl.create(:time_result, :competitor => @competitor)
  end
  it "is valid from FactoryGirl" do
    @tr.valid?.should == true
  end

  it "requires a competitor" do
    @tr.competitor = nil
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

  it "refers to a competitor" do
    @tr.competitor.should == @competitor
  end

  describe "when it has a time" do
    before(:each) do
      @tr.minutes = 19
      @tr.seconds = 16
      @tr.thousands = 701
    end
    it "can print the full time when all values exist" do
      @tr.full_time.should == "19:16.701"
    end
    it "doesn't print the values if it is disqualified" do
      @tr.status = "DQ"
      @tr.full_time.should == ""
    end
    it "shouldn't print the thousands if they are 0" do
      @tr.thousands = 0
      @tr.full_time.should == "19:16"
    end
    it "should only print tens, if the result is tens" do
      @tr.thousands = 100
      @tr.full_time.should == "19:16.1"
    end
    it "shouldn't print the thousands if they are 0, even for multi-hour events" do
      @tr.minutes = 200
      @tr.thousands = 0
      @tr.full_time.should == "3:20:16"
    end
  end

  it "can print the full time when the numbers start with 0" do
    @tr.minutes = 9
    @tr.seconds = 6
    @tr.thousands = 05
    @tr.full_time.should == "9:06.005"
  end

  it "can print the full time when the minutes are more than an hour" do
    @tr.minutes = 61
    @tr.seconds = 10
    @tr.thousands = 123

    @tr.full_time.should == "1:01:10.123"
  end

  it "can return the full time in thousands" do
    @tr.minutes = 1
    @tr.seconds = 2
    @tr.thousands = 3
    @tr.full_time_in_thousands.should == 62003
  end
end
