require 'spec_helper'

describe "convention_setup/event_configurations/advanced_settings" do
  before(:each) do
    @event_configuration = FactoryGirl.create(:event_configuration)
  end

  it "renders the advanced_settings event_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: update_advanced_settings_event_configuration_path, method: "post" do
      assert_select "input#event_configuration_standard_skill", name: "event_configuration[standard_skill]"
    end
  end
end
