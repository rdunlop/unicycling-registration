require 'spec_helper'

describe "convention_setup/events/edit" do
  before(:each) do
    @event = FactoryGirl.create(:event)
  end

  it "renders the edit event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_path(@event), :method => "post" do
      assert_select "select#event_category_id", :name => "event[category_id]"
    end
  end
end
