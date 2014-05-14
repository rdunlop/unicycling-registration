require 'spec_helper'

describe "registration_periods/index" do
  before(:each) do
    @registration_periods = [
      FactoryGirl.create(:registration_period),
      FactoryGirl.create(:registration_period)
    ]
  end

  it "renders a list of registration_periods" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "100.0", :count => 2
    assert_select "tr>td", :text => "50.0", :count => 2
    assert_select "tr>td", :text => "false", :count => 2
    assert_select "tr>td", :text => "Early Registration".to_s, :count => 2
  end
end
