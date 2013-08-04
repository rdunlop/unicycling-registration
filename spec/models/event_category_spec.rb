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

  describe "when it has an ag_group_type" do
    before(:each) do
      @ec.age_group_type = FactoryGirl.create(:age_group_type)
      @ec.save!
      @ec.reload
    end

    it "is updated when the age_group_type is updated" do
      @agt = @ec.age_group_type
      old_update_time = @ec.updated_at

      Delorean.jump 2

      @agt.save
      @ec.reload.updated_at.to_s.should_not == old_update_time.to_s
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
