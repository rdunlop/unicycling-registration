require 'spec_helper'

describe "events/index" do
  before(:each) do
    @ev1 = FactoryGirl.create(:event)
    @ev2 = FactoryGirl.create(:event)
    assign(:events, [
           @ev1, @ev2
    ])
    @category = @ev1.category
    @event = Event.new
  end

  it "renders a list of events" do
    render
    assert_select "h2", :text => "Category: " + @category.to_s
    # This is the same label 4x, because 2 for the event names, and  2 for the event_choice names
    assert_select "tr>td", :text => @ev1.to_s, :count => 4
  end

  it "renders new event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => category_events_path(@category), :method => "post" do
      assert_select "input#event_description", :name => "event[description]"
      assert_select "input#event_position", :name => "event[position]"
    end
  end
end
