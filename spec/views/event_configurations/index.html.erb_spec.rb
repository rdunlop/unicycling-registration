require 'spec_helper'

describe "event_configurations/index" do
  before(:each) do
    @ec = FactoryGirl.create(:event_configuration)
    assign(:event_configurations, [
           @ec
    ])
  end

  it "renders a list of event_configurations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "My conv".to_s, :count => 1
    assert_select "tr>td", :text => "Some really nice convention".to_s, :count => 1
    assert_select "tr>td", :text => "Somewhere".to_s, :count => 1
    assert_select "tr>td", :text => "X through Y".to_s, :count => 1
    assert_select "tr>td", :text => "http://www.naucc.com".to_s, :count => 1
    assert_select "tr>td", :text => "$".to_s, :count => 1
    assert_select "tr>td", :text => @ec.contact_email.to_s, :count => 1
    assert_select "tr>td", :text => false.to_s, :count => 1
    assert_select "tr>td", :text => true.to_s, :count => 1
  end
end
