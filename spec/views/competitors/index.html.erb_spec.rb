require 'spec_helper'

describe "competitors/index" do
    before(:each) do
      @comp = assign(:competitor, FactoryGirl.create(:event_competitor))
      @ec = @comp.competition
      assign(:competition, @ec)
      assign(:competitors, [@comp])
      assign(:registrants, [FactoryGirl.create(:registrant)])
    end

    it "renders add competitor form" do
      render

      assert_select "form", :count => 1
    end
end
