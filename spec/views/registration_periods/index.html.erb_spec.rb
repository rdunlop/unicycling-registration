require 'spec_helper'

describe "registration_periods/index" do
  before(:each) do
    assign(:registration_periods, [
      stub_model(RegistrationPeriod,
        :competitor_cost => 1,
        :noncompetitor_cost => 2,
        :name => "Name"
      ),
      stub_model(RegistrationPeriod,
        :competitor_cost => 1,
        :noncompetitor_cost => 2,
        :name => "Name"
      )
    ])
  end

  it "renders a list of registration_periods" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
