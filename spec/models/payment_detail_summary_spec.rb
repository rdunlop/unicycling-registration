require 'spec_helper'

describe PaymentDetailSummary do
  before do
    @pds = FactoryBot.create(:payment_detail_summary)
  end

  it "has the to_s of the associated expense_item" do
    expect(@pds.to_s).to eq(@pds.line_item.to_s)
  end

  context "when detail_summary has fractions of dollar" do
    before do
      @pds = FactoryBot.create(:payment_detail_summary, amount: "9.99")
    end

    it "doesn't round things to the nearest dollar" do
      expect(@pds.amount_cents).to eq(999)
    end
  end
end
