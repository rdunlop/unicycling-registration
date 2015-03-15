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
    expect(rendered).to match(/boolean/)
    expect(rendered).to match(/Multiple Values/)
    expect(rendered).to match(/Label/)
    expect(rendered).to match(/2/)
  end
end
