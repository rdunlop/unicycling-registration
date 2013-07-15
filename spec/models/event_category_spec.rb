require 'spec_helper'

describe EventCategory do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
  end
  it "is valid from FactoryGirl" do
    @ec.valid?.should == true
  end

  it "requires a name" do
    @ec.name = nil
    @ec.valid?.should == false
  end

  describe "with a user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    it "says there are no judges" do
      @ec.has_judge(@user).should == false
      @ec.get_judge(@user).should == nil
    end

    describe "as a judge" do
      before(:each) do
        @judge = FactoryGirl.create(:judge, :event_category => @ec, :user => @user)
      end

      it "has judge" do
        @ec.has_judge(@user).should == true
        @ec.get_judge(@user).should == @judge
      end
    end
  end

  it "has an event" do
    @ec.event.should == @ev
  end

  it "uses the event name in its name" do
    @ec.to_s.should == @ev.to_s + " - " + @ec.name
  end

  it "can have an age_group_type" do
    @ec.age_group_type = FactoryGirl.create(:age_group_type)
    @ec.valid?.should == true
  end

  describe "with some registrant_choices" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec)
    end

    it "has associated registrant_event_sign_ups" do
      @ec.registrant_event_sign_ups.should == [@rc]
    end

    it "can count the number of signed_up competitors" do
      @ec.num_competitors.should == 1
    end
  end

  describe "with some time_results" do
    before(:each) do
      @tr = FactoryGirl.create(:time_result, :event_category => @ec)
    end

    it "has associated time_results" do
      @ec.time_results.should == [@tr]
    end
  end
end
