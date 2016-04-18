# == Schema Information
#
# Table name: event_categories
#
#  id                              :integer          not null, primary key
#  event_id                        :integer
#  position                        :integer
#  name                            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  age_range_start                 :integer          default(0)
#  age_range_end                   :integer          default(100)
#  warning_on_registration_summary :boolean          default(FALSE), not null
#
# Indexes
#
#  index_event_categories_event_id              (event_id,position)
#  index_event_categories_on_event_id_and_name  (event_id,name) UNIQUE
#

require 'spec_helper'

describe EventCategory do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
  end
  it "is valid from FactoryGirl" do
    expect(@ec.valid?).to eq(true)
  end

  it "requires a name" do
    @ec.name = nil
    expect(@ec.valid?).to eq(false)
  end

  it "has an event" do
    expect(@ec.event).to eq(@ev)
  end

  it "uses the event name in its name" do
    expect(@ec.to_s).to eq(@ev.to_s + " - " + @ec.name)
  end

  it "can determine if an age is in range" do
    @ec.age_range_start = 1
    @ec.age_range_end = 10
    expect(@ec.age_is_in_range(1)).to eq(true)
    expect(@ec.age_is_in_range(10)).to eq(true)
    expect(@ec.age_is_in_range(4)).to eq(true)
    expect(@ec.age_is_in_range(40)).to eq(false)
  end

  describe "with some registrant_choices" do
    before(:each) do
      @rc = FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec)
    end

    it "has associated registrant_event_sign_ups" do
      expect(@ec.registrant_event_sign_ups).to eq([@rc])
    end

    it "can count the number of signed_up competitors" do
      expect(@ec.num_signed_up_registrants).to eq(1)
    end
  end

  it "touching an event_category touches an event" do
    @event = @ec.event
    old_update_time = @event.updated_at

    travel 2.seconds do
      @ec.touch
    end

    expect(@event.reload.updated_at.to_s).not_to eq(old_update_time.to_s)
  end

  describe "with a signed up, but deleted registrant" do
    before :each do
      reg = FactoryGirl.create(:registrant)
      FactoryGirl.create(:registrant_event_sign_up, event: @ev, event_category: @ec, signed_up: true, registrant: reg)
      reg.deleted = true
      reg.save!
    end

    it "doesn't list the reg" do
      expect(@ec.signed_up_registrants).to eq([])
    end
  end
end
