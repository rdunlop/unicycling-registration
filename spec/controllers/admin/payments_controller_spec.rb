require 'spec_helper'

describe Admin::PaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, :completed => true) }
  let!(:other_payment) { FactoryGirl.create(:payment) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, :payment => payment, :amount => 5.22) }


  describe "GET index" do
    it "assigns all payments as @payments" do
      get :index, {}
      assigns(:payments).should eq([payment, other_payment])
    end

    it "has the total_received" do
      get :index, {}
      assigns(:total_received).should  == 5.22
    end

    it "assigns the known expense groups as expense_groups" do
      group = payment_detail.expense_item.expense_group
      get :index, {}
      assigns(:expense_groups).should == [group]
    end
    it "assigns a set of expense_items as paid_expense_items" do
      get :index, {}
      assigns(:paid_expense_items).should == [payment_detail.expense_item]
    end
    it "doesn't assign unpaid expense_items" do
      FactoryGirl.create(:expense_item)
      get :index, {}
      assigns(:paid_expense_items).should == [payment_detail.expense_item]
    end
    it "assigns a set of expense_items as all_expense_items" do
      get :index, {}
      assigns(:all_expense_items).should == [payment_detail.expense_item]
    end
  end

  describe "POST create" do
    before(:each) do
      @ei = FactoryGirl.create(:expense_item)
      @reg = FactoryGirl.create(:registrant)
    end

    it "can create a payment" do
      expect {
        post :create, {:payment => {
        :note => "Volunteered",
        :payment_details_attributes => [
          {
        :registrant_id => @reg.id,
        :expense_item_id => @ei.id,
        :details => "Additional Details"
        }]
        }}
      }.to change(Payment, :count).by(1)
      p = Payment.last
      p.note.should == "Volunteered"
      p.completed.should == true
      pd = PaymentDetail.last
      pd.amount.should == @ei.cost
    end
    it "can handle receiving incomplete payment_details" do
      expect {
        post :create, {:payment => {
        :note => "Volunteered",
        :payment_details_attributes => [
          {
        :registrant_id => @reg.id,
        :expense_item_id => @ei.id,
        :details => "Additional Details"
          },
          {
        :registrant_id => '',
        :expense_item_id => @ei.id,
        :details => "Additional Details"
        }]
        }}
      }.to change(PaymentDetail, :count).by(1)
    end
  end
end
