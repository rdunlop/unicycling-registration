require 'spec_helper'

describe PaymentAdjustmentsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, :completed => true) }
  let!(:other_payment) { FactoryGirl.create(:payment) }
  let!(:payment_detail) { FactoryGirl.create(:payment_detail, :payment => payment, :amount => 5.22) }


  describe "GET list" do
    it "assigns all payments as @payments" do
      get :list, {}
      assigns(:payments).should eq([payment, other_payment])
    end
  end

  describe "POST refund_create" do
    before(:each) do
      @pd = FactoryGirl.create(:payment_detail)
    end

    it "can create a payment with refund elements" do
      expect {
        post :refund_create, {:refund_presenter => {
        :note => "Cancelled",
        :paid_details_attributes => {
          "0" => {
          :payment_detail_id => @pd.id,
          :refund => true
          }}
        }}
      }.to change(RefundDetail, :count).by(1)
      r = Refund.last
      r.note.should eq("Cancelled")
      rd = RefundDetail.last
      rd.payment_detail.should == @pd
    end
  end
end
