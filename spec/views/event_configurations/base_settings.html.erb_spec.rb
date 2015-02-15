require 'spec_helper'

describe "event_configurations/base_settings" do
  before(:each) do
    @event_configuration = FactoryGirl.create(:event_configuration)
  end

  it "renders the base_settings event_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_configurations_path(@event_configuration), :method => "post" do
      assert_select "input#event_configuration_contact_email", :name => "event_configuration[contact_email]"
    end
  end
end
