require 'spec_helper'
require 'cgi'

describe PaymentPresenter do
  before(:each) do
    @pay = PaymentPresenter.new
  end

  it "requires that the note be set" do
    @pay.user = FactoryGirl.create(:admin_user)
    expect(@pay.valid?).to eq(false)
    @pay.note = "Hello"
    expect(@pay.valid?).to eq(true)
  end

  it "has some new_details" do
    expect(@pay.new_details.size).to eq(5)
  end

  describe "when a registrant has paid for something" do
    before(:each) do
      @reg = FactoryGirl.create(:competitor)
      @payment = FactoryGirl.create(:payment, :completed => true)
      @pd = FactoryGirl.create(:payment_detail, :payment => @payment, :registrant => @reg, :details => "Some details")
    end

    it "has paid_items for the registrant" do
      @reg.reload
      expect(@reg.paid_details.size).to eq(1)
    end

    it "lists the paid items for the registrant" do
      @pay.add_registrant(@reg)
      expect(@pay.paid_details.size).to eq(1)
    end

    it "lists all registrants as @registrants" do
      expect(@pay.registrants).to eq([])
      @pay.add_registrant(@reg)
      expect(@pay.registrants).to eq([@reg])
    end

    it "includes the details in the payment_detail_presenter" do
      @pay.add_registrant(@reg)
      pdp = @pay.paid_details.first
      expect(pdp.details).to eq("Some details")
    end
  end

  describe "when a registrant has selected something, but not paid for" do
    before(:each) do
      @reg = FactoryGirl.create(:competitor)
      @rei = FactoryGirl.create(:registrant_expense_item, :registrant => @reg, :details => "Some other details")
      @reg.reload
    end
    it "has unpaid_details" do
      expect(@reg.owing_registrant_expense_items.size).to eq(1)
    end

    it "lists the unpaid items for the registrant" do
      @pay.add_registrant(@reg)
      expect(@pay.unpaid_details.size).to eq(1)
    end

    it "lists all registrants as @registrants" do
      @pay.add_registrant(@reg)
      expect(@pay.registrants).to eq([@reg])
    end
    it "includes the details in the payment_detail_presenter" do
      @pay.add_registrant(@reg)
      pdp = @pay.unpaid_details.first
      expect(pdp.details).to eq("Some other details")
    end
  end
end
