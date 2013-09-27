require 'spec_helper'

describe "payments/new" do
  before(:each) do
    @payment = FactoryGirl.create(:payment)
    @pd = FactoryGirl.create(:payment_detail, :payment => @payment, :amount => 10.11, :details => "Hello Werld")
    @payment.reload
  end

  it "renders new payment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => payments_path, :method => "post" do
      assert_select "input#payment_payment_details_attributes_0_amount", :value => @pd.amount
      assert_select "input#payment_payment_details_attributes_0_details", :value => "DHelo"
    end
  end
end
