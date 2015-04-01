require 'spec_helper'

describe "convention_setup/event_choices/index" do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @event_choices = [
      FactoryGirl.create(:event_choice,
                         :event => @event,
                         :cell_type => "multiple",
                         :multiple_values => "Multiple Values",
                         :label => "Label"
                        ),
      FactoryGirl.create(:event_choice,
                         :event => @event,
                         :cell_type => "multiple",
                         :multiple_values => "Multiple Values",
                         :label => "Label"
                        )
    ]
    @event_choice = EventChoice.new
  end

  it "renders a list of event_choices" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "multiple".to_s, :count => 2
    assert_select "tr>td", :text => "Multiple Values".to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
  end

  it "renders new event_choice form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => convention_setup_event_event_choices_path(@event), :method => "post" do
      assert_select "select#event_choice_cell_type", :name => "event_choice[cell_type]"
      assert_select "input#event_choice_multiple_values", :name => "event_choice[multiple_values]"
    end
  end
end
