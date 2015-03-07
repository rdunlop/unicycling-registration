require 'spec_helper'

describe "convention_setup/event_choices/show" do
  before(:each) do
    @event = FactoryGirl.create(:event)
    @event_choice = FactoryGirl.create(:event_choice,
                                       :event => @event,
                                       :cell_type => "boolean",
                                       :multiple_values => "Multiple Values",
                                       :label => "Label",
                                       :position => 2
    )
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/boolean/)
    rendered.should match(/Multiple Values/)
    rendered.should match(/Label/)
    rendered.should match(/2/)
  end
end
