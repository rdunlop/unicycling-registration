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

  it "has an event" do
    @ec.event.should == @ev
  end

  it "uses the event name in its name" do
    @ec.to_s.should == @ev.to_s + " - " + @ec.name
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

  it "touching an event_category touches an event" do
    @event = @ec.event
    old_update_time = @event.updated_at

    Delorean.jump 2

    @ec.touch
    @event.reload.updated_at.to_s.should_not == old_update_time.to_s
  end
end
