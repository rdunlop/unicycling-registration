require 'spec_helper'

describe "convention_setup/event_choices/edit" do
  before(:each) do
    @event_choices = []
    @event_choice = FactoryGirl.create(:event_choice)
  end

  it "renders the edit event_choice form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => convention_setup_event_choice_path(@event_choice), :method => "post" do
      assert_select "select#event_choice_cell_type", :name => "event_choice[cell_type]"
      assert_select "input#event_choice_multiple_values", :name => "event_choice[multiple_values]"
      assert_select "input#event_choice_autocomplete", :name => "event_choice[autocomplete]"
    end
  end
end
