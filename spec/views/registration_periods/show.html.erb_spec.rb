require 'spec_helper'

describe "registration_periods/show" do
  before(:each) do
    @registration_period = FactoryGirl.create(:registration_period)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/#{@registration_period.competitor_expense_item.cost}/)
    rendered.should match(/#{@registration_period.noncompetitor_expense_item.cost}/)
    rendered.should match(/#{@registration_period.name}/)
  end
end
