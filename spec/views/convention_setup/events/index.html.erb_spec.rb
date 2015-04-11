require 'spec_helper'

describe "convention_setup/events/index" do
  before(:each) do
    @ev1 = FactoryGirl.create(:event, :name => "First name")
    @ev2 = FactoryGirl.create(:event, :name => "Second name")
    assign(:events, [
      @ev1, @ev2
    ])
    @category = @ev1.category
    @event = Event.new
  end

  it "renders a list of events" do
    render
    assert_select "h1", :text => "Events in Category: " + @category.to_s
    # This is the same label 2x, because 2 for the event names,
    assert_select "tr>th", :text => @ev1.to_s, :count => 1
    assert_select "tr>th", :text => @ev2.to_s, :count => 1
  end

  it "renders new event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => convention_setup_category_events_path(@category), :method => "post" do
      assert_select "input#event_name", :name => "event[name]"
    end
  end
end
