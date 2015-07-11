require 'spec_helper'

describe "payments/index" do
  before(:each) do
    @pay1 = FactoryGirl.create(:payment)
    @pay2 = FactoryGirl.create(:payment)
    assign(:payments, [
      @pay1, @pay2
    ])

    allow(controller).to receive(:current_user) { FactoryGirl.create(:user) }

    assign(:refunds, [])
  end

  it "renders a list of payments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", text: @pay1.transaction_id.to_s, count: 2
  end
end
