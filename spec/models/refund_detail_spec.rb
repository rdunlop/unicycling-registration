require 'spec_helper'

describe RefundDetail do
  before(:each) do
    @rd = FactoryGirl.create(:refund_detail)
  end

  it "has a valid rd from factoryGirl" do
    @rd.valid?.should == true
  end

  it "requires a payment_detail" do
    @rd.payment_detail = nil
    @rd.valid?.should == false
  end

  describe "when there is an active registration_period", :caching => true do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period)
    end
    it "re-creates the registration_expense_item successfully" do
      @reg = FactoryGirl.create(:competitor)
      @reg.registrant_expense_items.count.should == 1
      @pd = FactoryGirl.create(:payment_detail, :registrant => @reg, :expense_item => @rp.competitor_expense_item)
      payment = @pd.payment
      payment.reload
      payment.completed = true
      payment.save
      @reg.reload
      @reg.registrant_expense_items.count.should == 0
      @pd.registrant = @reg

      @pd.reload
      @rd1 = FactoryGirl.create(:refund_detail, :payment_detail => @pd)
      @reg.reload
      @reg.registrant_expense_items.count.should == 1
    end
  end
end
