require 'spec_helper'

describe EventCategory do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:event_category, :event => @event, :position => 1)
  end
  it "is valid from FactoryGirl" do
    @ec.valid?.should == true
  end

  it "requires a name" do
    @ec.name = nil
    @ec.valid?.should == false
  end

  it "has an event" do
    @ec.event.should == @event
  end

  it "can have an age_group_type" do
    @ec.age_group_type = FactoryGirl.create(:age_group_type)
    @ec.valid?.should == true
  end

  describe "with some registrant_choices" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_choice, :event_choice => FactoryGirl.create(:event_choice, :cell_type => "category"), :event_category => @ec)
    end

    it "has associated registrant_choices" do
      @ec.registrant_choices.should == [@rc]
    end
  end
end
