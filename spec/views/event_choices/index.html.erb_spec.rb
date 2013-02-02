require 'spec_helper'

describe "event_choices/index" do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @event_choices = [
      FactoryGirl.create(:event_choice,
                         :event => @event,
                         :export_name => "Export Name 1",
                         :cell_type => "multiple",
                         :multiple_values => "Multiple Values",
                         :label => "Label",
                         :position => 2
                        ),
                          FactoryGirl.create(:event_choice,
                                             :event => @event,
                                             :export_name => "Export Name 2",
                                             :cell_type => "multiple",
                                             :multiple_values => "Multiple Values",
                                             :label => "Label",
                                             :position => 3
                                            )
    ]
    @event_choice = EventChoice.new
  end

  it "renders a list of event_choices" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Export Name 1".to_s, :count => 1
    assert_select "tr>td", :text => "Export Name 2".to_s, :count => 1
    assert_select "tr>td", :text => "multiple".to_s, :count => 2
    assert_select "tr>td", :text => "Multiple Values".to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 1
    assert_select "tr>td", :text => 3.to_s, :count => 1
  end

  it "renders new event_choice form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_event_choices_path(@event), :method => "post" do
      assert_select "input#event_choice_export_name", :name => "event_choice[export_name]"
      assert_select "select#event_choice_cell_type", :name => "event_choice[cell_type]"
      assert_select "input#event_choice_multiple_values", :name => "event_choice[multiple_values]"
      assert_select "input#event_choice_label", :name => "event_choice[label]"
      assert_select "input#event_choice_position", :name => "event_choice[position]"
    end
  end
end
