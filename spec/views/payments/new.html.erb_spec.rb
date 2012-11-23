require 'spec_helper'

describe "payments/new" do
  before(:each) do
    @payment = FactoryGirl.create(:payment)
  end

  it "renders new payment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => payments_path, :method => "post" do
    end
  end
end
