require 'spec_helper'

describe "event_configurations/payment_settings" do
  before(:each) do
    assign(:event_configuration,
           FactoryGirl.create(:event_configuration))
  end

  it "renders event_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: event_configuration_path, method: "post" do
      assert_select "select#event_configuration_currency_code", name: "event_configuration[currency_code]"
    end
  end
end
