require 'spec_helper'

describe "payments/new" do
  before(:each) do
    @payment = FactoryGirl.create(:payment)
  end

  it "renders new payment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => payments_path, :method => "post" do
      assert_select "input#payment_user_id", :name => "payment[user_id]"
      assert_select "input#payment_completed", :name => "payment[completed]"
      assert_select "input#payment_cancelled", :name => "payment[cancelled]"
      assert_select "input#payment_transaction_id", :name => "payment[transaction_id]"
    end
  end
end
