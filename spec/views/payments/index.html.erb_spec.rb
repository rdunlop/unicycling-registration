require 'spec_helper'

describe "payments/index" do
  before(:each) do
    assign(:payments, [
           FactoryGirl.create(:payment),
           FactoryGirl.create(:payment)
    ])
  end

  it "renders a list of payments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 4
    assert_select "tr>td", :text => "Transaction".to_s, :count => 2
  end
end
