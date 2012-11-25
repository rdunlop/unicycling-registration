require 'spec_helper'

describe "event_choices/new" do
  before(:each) do
    @event_choice = FactoryGirl.create(:event_choice)
  end

  it "renders new event_choice form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_choices_path, :method => "post" do
      assert_select "select#event_choice_event_id", :name => "event_choice[event_id]"
      assert_select "input#event_choice_export_name", :name => "event_choice[export_name]"
      assert_select "select#event_choice_cell_type", :name => "event_choice[cell_type]"
      assert_select "input#event_choice_multiple_values", :name => "event_choice[multiple_values]"
      assert_select "input#event_choice_label", :name => "event_choice[label]"
      assert_select "input#event_choice_position", :name => "event_choice[position]"
    end
  end
end
