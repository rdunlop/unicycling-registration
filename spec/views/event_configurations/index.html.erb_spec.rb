require 'spec_helper'

describe "event_configurations/index" do
  let(:config) { FactoryGirl.create(:event_configuration, :iuf => false, :has_print_waiver => false, :has_online_waiver => false, :standard_skill => false, :usa => false, :usa_membership_config => false)}
  before(:each) do
    assign(:config, config)
    assign(:event_configurations, [
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
    assert_select "tr>td", :text => config.contact_email.to_s, :count => 1
    assert_select "tr>td", :text => true.to_s, :count => 1
    assert_select "tr>td", :text => false.to_s, :count => 7
  end
end
