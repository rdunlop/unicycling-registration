require 'spec_helper'
require 'cgi'

describe Payment do
  before(:each) do
    @pay = FactoryGirl.create(:payment)
  end

  it "can be created by FactoryGirl" do
    @pay.valid?.should == true
  end

  it "defaults completed to false" do
    p = Payment.new
    p.completed.should == false
  end

  it "defaults cancelled to false" do
    p = Payment.new
    p.cancelled.should == false
  end

  it "Requires user" do
    @pay.user = nil
    @pay.valid?.should == false
  end

  describe "with payment details" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail, :payment => @pay)
    end
    it "has payment_details" do
      @pay.payment_details.should == [@pd]
    end
    it "can calcalate the payment total-amount" do
      @pay.total_amount.should == @pd.amount
    end
  end

  describe "With an environment config with test mode disabled" do
    before(:each) do
      ENV["PAYPAL_TEST"] = "false"
    end
    it "has a REAL paypal_post_url" do
      @pay.paypal_post_url.should == "https://www.paypal.com/cgi-bin/webscr"
    end
  end

  it "saves associated details when the payment is saved" do
    pay = FactoryGirl.build(:payment)
    pd = pay.payment_details.build()
    pd.registrant = FactoryGirl.create(:registrant)
    pd.amount = 100
    pd.expense_item = FactoryGirl.create(:expense_item)
    PaymentDetail.all.count.should == 0
    pay.save
    PaymentDetail.all.count.should == 1
  end

  it "destroys related payment_details upon destroy" do
    pay = FactoryGirl.create(:payment)
    pd = FactoryGirl.create(:payment_detail, :payment => pay)
    PaymentDetail.all.count.should == 1
    pay.destroy
    PaymentDetail.all.count.should == 0
  end

  describe "with a completed payment" do
    let (:payment) { FactoryGirl.create(:payment, :completed => true) }

    it "can determien the toatl received" do
      pd = FactoryGirl.create(:payment_detail, :payment => payment, :amount => 15.33)
      Payment.total_received.should == 15.33
    end

    it "returns the set of paid expense_items" do
      pd = FactoryGirl.create(:payment_detail, :payment => payment, :amount => 15.33)
      Payment.paid_expense_items.should == [pd.expense_item]
    end
  end



  describe "a payment for a tshirt" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail, :payment => @pay)
      @reg = @pd.registrant
      @rei = FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @pd.expense_item)
      @reg.reload
    end

    it "registrant owes for this item" do
      @reg.owing_expense_items.should == [@rei.expense_item]
    end
    describe "when the user has a free t-shirt and a paid t-shirt" do
      before(:each) do
        @rei_free = FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @pd.expense_item, :free => true)
        @reg.reload
      end

      it "markes the correct one as paid when we pay for the non-free one" do
        @pay.completed = true
        @pay.save
        @reg.owing_registrant_expense_items.should == [@rei_free]
      end
      it "markes the correct one as paid when we pay for the free one" do
        @pd.free = true
        @pd.save
        @pay.completed = true
        @pay.save
        @reg.owing_registrant_expense_items.should == [@rei]
      end
    end
    describe "when the registrant has two t-shirts, who only differ by details" do
      before(:each) do
        @rei2 = FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @pd.expense_item, :details => "for My Kid")
        @reg.reload
      end

      it "marks the correct shirt as paid" do
        @pd.save
        @pay.completed = true
        @pay.save
        @reg.owing_registrant_expense_items.should == [@rei2]
      end
    end

    describe "when the payment is paid" do
      before(:each) do
        @pay.completed = true
        @pay.save
      end
      it "registrant no longer owes" do
        @reg.owing_expense_items.should == []
      end
      it "registrant has paid item" do
        @reg.paid_expense_items.should == [@pd.expense_item]
      end

      describe "when the payment is saved after being paid" do
        before(:each) do
          @rei2 = FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :expense_item => @pd.expense_item)
          @pay.save
          @reg.reload
        end
        it "doesn't remove more items from the registrant_expenses" do
          @reg.owing_expense_items.should == [@rei2.expense_item]
        end
      end
    end
  end
end
