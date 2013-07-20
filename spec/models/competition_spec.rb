require 'spec_helper'

describe Competition do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:competition, :event => @ev)
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
        @judge = FactoryGirl.create(:judge, :competition => @ec, :user => @user)
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
end
