require 'spec_helper'

describe Admin::PaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, :completed => true) }
  let!(:other_payment) { FactoryGirl.create(:payment) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, :payment => payment, :amount => 5.22) }

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
