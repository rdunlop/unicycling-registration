# == Schema Information
#
# Table name: event_categories
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  position        :integer
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  age_range_start :integer          default(0)
#  age_range_end   :integer          default(100)
#

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

  it "can determine if an age is in range" do
    @ec.age_range_start = 1
    @ec.age_range_end = 10
    @ec.age_is_in_range(1).should == true
    @ec.age_is_in_range(10).should == true
    @ec.age_is_in_range(4).should == true
    @ec.age_is_in_range(40).should == false
  end


  describe "with some registrant_choices" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec)
    end

    it "has associated registrant_event_sign_ups" do
      @ec.registrant_event_sign_ups.should == [@rc]
    end

    it "can count the number of signed_up competitors" do
      @ec.num_signed_up_registrants.should == 1
    end
  end

  it "touching an event_category touches an event" do
    @event = @ec.event
    old_update_time = @event.updated_at

    Delorean.jump 2

    @ec.touch
    @event.reload.updated_at.to_s.should_not == old_update_time.to_s
  end

  describe "with a signed up, but deleted registrant" do
    before :each do
      reg = FactoryGirl.create(:registrant)
      FactoryGirl.create(:registrant_event_sign_up, :event => @ev, :event_category => @ec, :signed_up => true, :registrant => reg)
      reg.deleted = true
      reg.save!
    end

    it "doesn't list the reg" do
      expect(@ec.signed_up_registrants).to eq([])
    end
  end
end
