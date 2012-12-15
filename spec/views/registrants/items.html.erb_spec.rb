require 'spec_helper'

describe "registrants/items" do
  before(:each) do
    @comp_exp = FactoryGirl.create(:expense_item, :cost => 100)
    @noncomp_exp = FactoryGirl.create(:expense_item, :cost => 50)
    @registration_period = FactoryGirl.create(:registration_period, 
                                              :start_date => Date.new(2012, 01, 10),
                                              :end_date => Date.new(2012, 02, 11),
                                              :competitor_expense_item => @comp_exp,
                                              :noncompetitor_expense_item => @noncomp_exp)
    @registrant = FactoryGirl.create(:competitor)
  end

  it "renders add_items form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => single_registrant_expenses_url, :method => "put"
  end
  it "displays the 'Save Registration' button" do
    render
    assert_select "input[value='Save + Continue']", 1
  end
end
