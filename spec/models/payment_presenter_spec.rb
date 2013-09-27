require 'spec_helper'
require 'cgi'

describe PaymentPresenter do
  before(:each) do
    @pay = PaymentPresenter.new
  end

  it "requires that the note be set" do
    @pay.user = FactoryGirl.create(:admin_user)
    @pay.valid?.should == false
    @pay.note = "Hello"
    @pay.valid?.should == true
  end

  it "has some new_details" do
    @pay.new_details.size.should == 5
  end

  describe "when a registrant has paid for something" do
    before(:each) do
      @reg = FactoryGirl.create(:competitor)
      @payment = FactoryGirl.create(:payment, :completed => true)
      @pd = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @reg)
    end

    it "has paid_items for the registrant" do
      @reg.reload
      @reg.paid_details.size.should == 1
    end

    it "lists the paid items for the registrant" do
      @pay.add_registrant(@reg)
      @pay.paid_details.size.should == 1
    end

    it "lists all registrants as @registrants" do
      @pay.registrants.should == []
      @pay.add_registrant(@reg)
      @pay.registrants.should == [@reg]
    end
  end

  describe "when a registrant has selected something, but not paid for" do
    before(:each) do
      @reg = FactoryGirl.create(:competitor)
      @rei = FactoryGirl.create(:registrant_expense_item, :registrant => @reg)
      @reg.reload
    end
    it "has unpaid_details" do
      @reg.owing_registrant_expense_items.size.should == 1
    end

    it "lists the unpaid items for the registrant" do
      @pay.add_registrant(@reg)
      @pay.unpaid_details.size.should == 1
    end

    it "lists all registrants as @registrants" do
      @pay.add_registrant(@reg)
      @pay.registrants.should == [@reg]
    end
  end
end
