require 'spec_helper'

describe "registration_periods/show" do
  before(:each) do
    @registration_period = assign(:registration_period, stub_model(RegistrationPeriod,
      :competitor_cost => 1,
      :noncompetitor_cost => 2,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Name/)
  end
end
