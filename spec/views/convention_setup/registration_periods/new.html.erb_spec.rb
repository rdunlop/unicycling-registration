require 'spec_helper'

describe "convention_setup/registration_periods/new" do
  before(:each) do
    @registration_period = FactoryGirl.build(:registration_period)
    @registration_period.build_competitor_expense_item
    @registration_period.build_noncompetitor_expense_item
  end

  it "renders new registration_period form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: registration_periods_path, method: "post" do
      assert_select "input#registration_period_competitor_expense_item_attributes_cost", name: "registration_period[competitor_expense_item_attributes][cost]"
      assert_select "input#registration_period_noncompetitor_expense_item_attributes_cost", name: "registration_period[noncompetitor_expense_item_attributes][cost]"
    end
  end
end
