require 'spec_helper'

describe EmailFilters::Event do
  describe "with a registrant signed up for an event" do
    before do
      @reg = FactoryGirl.create(:competitor)
      resu = FactoryGirl.create(:registrant_event_sign_up, registrant: @reg)
      @reg_not_signed_up = FactoryGirl.create(:competitor)
      @event = resu.event
    end

    it "can create a list via the event id" do
      @filter = described_class.new(@event.id)
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
