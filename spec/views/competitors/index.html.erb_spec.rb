require 'spec_helper'

describe "competitors/index" do
    before(:each) do
      @comp = assign(:competitor, FactoryGirl.create(:event_competitor))
      @ec = @comp.competition
      assign(:competition, @ec)
      assign(:competitors, [@comp])
      assign(:all_registrants, [])
    end

    it "doesn't render new competitor form" do
      render

      assert_select "tr>td", :text => @comp.name.to_s, :count => 0
    end
end
