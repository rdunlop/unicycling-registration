require 'spec_helper'

describe "events/new" do
  before(:each) do
    assign(:event, stub_model(Event,
      :name => "MyString",
      :category_id => 1,
      :description => "MyString",
      :position => 1
    ).as_new_record)
  end

  it "renders new event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => events_path, :method => "post" do
      assert_select "input#event_name", :name => "event[name]"
      assert_select "select#event_category_id", :name => "event[category_id]"
      assert_select "input#event_description", :name => "event[description]"
      assert_select "input#event_position", :name => "event[position]"
    end
  end
end
