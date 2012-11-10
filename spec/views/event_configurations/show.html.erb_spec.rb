require 'spec_helper'

describe "event_configurations/show" do
  before(:each) do
    @event_configuration = assign(:event_configuration, stub_model(EventConfiguration,
      :short_name => "Short Name",
      :long_name => "Long Name",
      :location => "Location",
      :dates_description => "Dates Description",
      :event_url => "Event Url",
      :logo => "",
      :currency => "Currency",
      :contact_email => "Contact Email",
      :closed => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Short Name/)
    rendered.should match(/Long Name/)
    rendered.should match(/Location/)
    rendered.should match(/Dates Description/)
    rendered.should match(/Event Url/)
    rendered.should match(//)
    rendered.should match(/Currency/)
    rendered.should match(/Contact Email/)
    rendered.should match(/false/)
  end
end
