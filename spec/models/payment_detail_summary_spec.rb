require 'spec_helper'

describe PaymentDetailSummary do
  before(:each) do
    @pds = FactoryGirl.create(:payment_detail_summary)
  end

  it "has the to_s of the associated expense_item" do
    expect(@pds.to_s).to eq(@pds.expense_item.to_s)
  end
end
