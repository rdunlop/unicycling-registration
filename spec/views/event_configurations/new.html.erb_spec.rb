require 'spec_helper'

describe "event_configurations/new" do
  before(:each) do
    assign(:event_configuration, 
           FactoryGirl.create(:event_configuration))
  end

  it "renders new event_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_configurations_path, :method => "post" do
      assert_select "input#event_configuration_short_name", :name => "event_configuration[short_name]"
      assert_select "input#event_configuration_long_name", :name => "event_configuration[long_name]"
      assert_select "input#event_configuration_location", :name => "event_configuration[location]"
      assert_select "input#event_configuration_dates_description", :name => "event_configuration[dates_description]"
      assert_select "input#event_configuration_event_url", :name => "event_configuration[event_url]"
      assert_select "input#event_configuration_logo_image", :name => "event_configuration[logo_image]"
      assert_select "input#event_configuration_currency", :name => "event_configuration[currency]"
      assert_select "input#event_configuration_contact_email", :name => "event_configuration[contact_email]"
      assert_select "input#event_configuration_test_mode", :name => "event_configuration[test_mode]"
      assert_select "select#event_configuration_competitor_free_item_expense_group_id", :name => "event_configuration[competitor_free_item_expense_group_id]"
      assert_select "select#event_configuration_noncompetitor_free_item_expense_group_id", :name => "event_configuration[noncompetitor_free_item_expense_group_id]"
    end
  end
end
