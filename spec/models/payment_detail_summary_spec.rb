require 'spec_helper'

describe PaymentDetailSummary do
  before(:each) do
    @pds = FactoryGirl.create(:payment_detail_summary)
  end

  it "has the to_s of the associated expense_item" do
    @pds.to_s.should == @pds.expense_item.to_s
  end
end
