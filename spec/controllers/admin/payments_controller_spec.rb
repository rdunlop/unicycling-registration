require 'spec_helper'

describe Admin::PaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end
  let!(:payment) { FactoryGirl.create(:payment, :completed => true) }
  let!(:other_payment) { FactoryGirl.create(:payment) }


  describe "GET index" do
    it "assigns all payments as @payments" do
      get :index, {}
      assigns(:payments).should eq([payment, other_payment])
    end

    it "has the total_received" do
      FactoryGirl.create(:payment_detail, :payment => payment, :amount => 5.22)
      get :index, {}
      assigns(:total_received).should  == 5.22
    end
  end

end
