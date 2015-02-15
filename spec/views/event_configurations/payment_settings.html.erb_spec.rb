require 'spec_helper'

describe "event_configurations/payment_settings" do
  before(:each) do
    assign(:event_configuration,
           FactoryGirl.create(:event_configuration))
  end

  it "renders event_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_configurations_path, :method => "post" do
      assert_select "input#event_configuration_currency", :name => "event_configuration[currency]"
    end
  end
end
