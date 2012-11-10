require 'spec_helper'

describe "event_configurations/index" do
  before(:each) do
    assign(:event_configurations, [
      stub_model(EventConfiguration,
        :short_name => "Short Name",
        :long_name => "Long Name",
        :location => "Location",
        :dates_description => "Dates Description",
        :event_url => "Event Url",
        :logo => "",
        :currency => "Currency",
        :contact_email => "Contact Email",
        :closed => false
      ),
      stub_model(EventConfiguration,
        :short_name => "Short Name",
        :long_name => "Long Name",
        :location => "Location",
        :dates_description => "Dates Description",
        :event_url => "Event Url",
        :logo => "",
        :currency => "Currency",
        :contact_email => "Contact Email",
        :closed => false
      )
    ])
  end

  it "renders a list of event_configurations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Short Name".to_s, :count => 2
    assert_select "tr>td", :text => "Long Name".to_s, :count => 2
    assert_select "tr>td", :text => "Location".to_s, :count => 2
    assert_select "tr>td", :text => "Dates Description".to_s, :count => 2
    assert_select "tr>td", :text => "Event Url".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Currency".to_s, :count => 2
    assert_select "tr>td", :text => "Contact Email".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
