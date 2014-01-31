require 'spec_helper'

describe "events/show" do
  before(:each) do
    @event = FactoryGirl.create(:event, :name => "First name")
  end

  it "renders a list of categories" do
    render

    assert_select "th", :text => "Event-Category"
    # This is the same label 2x, because 2 for the event names,
    assert_select "tr>td", :text => @event.event_categories.first.to_s, :count => 1
  end

  it "renders list of all competitions" do
    @competition = FactoryGirl.create(:competition, :event => @event)
    @event.reload
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => @competition.to_s, :count => 1
  end
end
