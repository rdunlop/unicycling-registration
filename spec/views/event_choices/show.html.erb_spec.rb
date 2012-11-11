require 'spec_helper'

describe "event_choices/show" do
  before(:each) do
    @event_choice = assign(:event_choice, stub_model(EventChoice,
      :event_id => 1,
      :export_name => "Export Name",
      :cell_type => "Cell Type",
      :multiple_values => "Multiple Values",
      :label => "Label",
      :position => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Export Name/)
    rendered.should match(/Cell Type/)
    rendered.should match(/Multiple Values/)
    rendered.should match(/Label/)
    rendered.should match(/2/)
  end
end
