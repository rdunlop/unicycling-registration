require 'spec_helper'

describe "registration_periods/new" do
  before(:each) do
    assign(:registration_period, stub_model(RegistrationPeriod,
      :competitor_cost => 1,
      :noncompetitor_cost => 1,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new registration_period form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registration_periods_path, :method => "post" do
      assert_select "input#registration_period_competitor_cost", :name => "registration_period[competitor_cost]"
      assert_select "input#registration_period_noncompetitor_cost", :name => "registration_period[noncompetitor_cost]"
      assert_select "input#registration_period_name", :name => "registration_period[name]"
    end
  end
end
