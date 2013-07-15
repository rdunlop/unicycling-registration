require 'spec_helper'

describe "distance_attempts/list" do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
    assign(:event, @ev)

    @comp1 = FactoryGirl.create(:event_competitor, :event_category => @ec)
    @comp2 = FactoryGirl.create(:event_competitor, :event_category => @ec)
    @judge = FactoryGirl.create(:judge)

    @da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp1, :judge => @judge)

    assign(:distance_attempts, [@da1])
  end

  it "renders a table containing all of the distance attempts" do
    render

    assert_select "tr>td", :text => @da1.distance, :count => 1
    assert_select "tr>td", :text => @da1.fault ? "yes":"no", :count => 1
    assert_select "tr>td", :text => @comp1.name, :count => 1
    assert_select "tr>td", :text => @comp1.age, :count => 1
    assert_select "tr>td", :text => @judge.name, :count => 1
    assert_select "tr>td", :text => @da1.created_at, :count => 1
  end
end
