require 'spec_helper'

describe PaymentDetail do
  before(:each) do
    @pd = FactoryGirl.create(:payment_detail)
  end

  it "can be cerated by factory" do
    @pd.valid?.should == true
  end

  it "must have a payment" do
    @pd.payment = nil
    @pd.valid?.should == false
  end

  it "does not allow negative amounts" do
    @pd.amount = -1
    @pd.valid?.should == false
  end

  it "must have a registrant" do
    @pd.registrant = nil
    @pd.valid?.should == false
  end

  it "must have an amount" do
    @pd.amount = nil
    @pd.valid?.should == false
  end
  it "must have an item" do
    @pd.expense_item = nil
    @pd.valid?.should == false
  end
  it "has additional description if it is refunded" do
    @pd.refunded?.should == false
    @pd.to_s.should == @pd.expense_item.to_s
    @ref = FactoryGirl.create(:refund_detail, :payment_detail => @pd)
    @pd.reload
    @pd.refunded?.should == true
    @pd.to_s.should == "#{@pd.expense_item.to_s} (Refunded)"
  end

  it "indicates that it is a refund if it has an associated refund_detail" do
    @pd.refunded?.should == false
    @ref = FactoryGirl.create(:refund_detail, :payment_detail => @pd)
    @pd.reload
    @pd.refunded?.should == true
    @ref.percentage.should == 100
    @pd.cost.should == 0
  end

  it "it marks the cost as partial if the refund is not 100%" do
    @pd.refunded?.should == false
    @refund_detail = FactoryGirl.create(:refund_detail, :payment_detail => @pd)
    @refund = @refund_detail.refund
    @refund.percentage = 50
    @refund.save!
    @pd.reload
    @pd.refunded?.should == true
    @pd.cost.should == @pd.amount / 2.0
  end

  it "is not refunded by default" do
    pay = PaymentDetail.new
    pay.refunded?.should == false
  end

  it "is not scoped as completed if not completed" do
    @pd.payment.completed.should == false
    PaymentDetail.completed.should == []
  end

  describe "when a payment is completed" do
    before(:each) do
      pay = @pd.payment
      pay.completed = true
      pay.save!
    end
    it "is scoped as completed when payment is completed" do
      PaymentDetail.completed.should == [@pd]
    end

    it "doesn't list refunded payments" do
      @ref = FactoryGirl.create(:refund_detail, :payment_detail => @pd)
      PaymentDetail.completed.should == []
    end
  end
end
