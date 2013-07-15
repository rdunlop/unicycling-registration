require 'spec_helper'

describe "competitors/index" do
    before(:each) do
      @comp = assign(:competitor, FactoryGirl.create(:event_competitor))
      @ec = @comp.event_category
      assign(:event_category, @ec)
      assign(:competitors, [@comp])
    end

    it "renders new competitor form" do
      render

      assert_select "tr>td", :text => @comp.name.to_s, :count => 1
    end
end
