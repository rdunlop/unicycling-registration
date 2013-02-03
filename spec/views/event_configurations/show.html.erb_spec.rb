require 'spec_helper'

describe "event_configurations/show" do
  before(:each) do
    @event_configuration = FactoryGirl.create(:event_configuration)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/My conv/)
    rendered.should match(/Some really nice convention/)
    rendered.should match(/Somewhere/)
    rendered.should match(/X through Y/)
    rendered.should match(/http:\/\/www.naucc.com/)
    rendered.should match(/$/)
    rendered.should match(@event_configuration.contact_email)
    rendered.should match(/false/)
  end
end
