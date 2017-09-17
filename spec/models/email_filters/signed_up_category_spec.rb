require 'spec_helper'

describe EmailFilters::SignedUpCategory do
  describe "with a registrant signed up for an event" do
    before do
      @reg = FactoryGirl.create(:competitor)
      resu = FactoryGirl.create(:registrant_event_sign_up, registrant: @reg)
      @reg_not_signed_up = FactoryGirl.create(:competitor)
      @event = resu.event
    end

    it "can include the email in a category-search email" do
      @filter = described_class.new(@event.category.id)
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
