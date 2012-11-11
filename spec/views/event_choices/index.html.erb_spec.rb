require 'spec_helper'

describe "event_choices/index" do
  before(:each) do
    assign(:event_choices, [
      stub_model(EventChoice,
        :event_id => 1,
        :export_name => "Export Name",
        :cell_type => "Cell Type",
        :multiple_values => "Multiple Values",
        :label => "Label",
        :position => 2
      ),
      stub_model(EventChoice,
        :event_id => 1,
        :export_name => "Export Name",
        :cell_type => "Cell Type",
        :multiple_values => "Multiple Values",
        :label => "Label",
        :position => 2
      )
    ])
  end

  it "renders a list of event_choices" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Export Name".to_s, :count => 2
    assert_select "tr>td", :text => "Cell Type".to_s, :count => 2
    assert_select "tr>td", :text => "Multiple Values".to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
