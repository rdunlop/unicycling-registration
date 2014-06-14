require 'spec_helper'

describe "event_configurations/edit" do
  before(:each) do
    @event_configuration = FactoryGirl.create(:event_configuration)
  end

  it "renders the edit event_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_configurations_path(@event_configuration), :method => "post" do
      assert_select "input#event_configuration_event_url", :name => "event_configuration[event_url]"
      assert_select "input#event_configuration_logo_file", :name => "event_configuration[logo_file]"
      assert_select "input#event_configuration_currency", :name => "event_configuration[currency]"
      assert_select "input#event_configuration_contact_email", :name => "event_configuration[contact_email]"
      assert_select "input#event_configuration_test_mode", :name => "event_configuration[test_mode]"
    end
  end
end
