require 'spec_helper'

describe "payments/edit" do
  before(:each) do
    @payment = assign(:payment, stub_model(Payment,
      :user_id => 1,
      :completed => false,
      :cancelled => false,
      :transaction_id => "MyString"
    ))
  end

  it "renders the edit payment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => payments_path(@payment), :method => "post" do
      assert_select "input#payment_user_id", :name => "payment[user_id]"
      assert_select "input#payment_completed", :name => "payment[completed]"
      assert_select "input#payment_cancelled", :name => "payment[cancelled]"
      assert_select "input#payment_transaction_id", :name => "payment[transaction_id]"
    end
  end
end
