require 'spec_helper'

describe "registration_periods/edit" do
  before(:each) do
    @registration_period = FactoryGirl.create(:registration_period)
  end

  it "renders the edit registration_period form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registration_periods_path(@registration_period), :method => "post" do
      assert_select "select#registration_period_competitor_expense_item_id", :name => "registration_period[competitor_expense_item_id]"
      assert_select "select#registration_period_noncompetitor_expense_item_id", :name => "registration_period[noncompetitor_expense_item_id]"
      assert_select "input#registration_period_onsite", :name => "registration_period[onsite]"
    end
  end
end
