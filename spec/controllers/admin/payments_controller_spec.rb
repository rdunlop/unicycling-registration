require 'spec_helper'

describe Admin::PaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end


  describe "GET index" do
    it "assigns all payments as @payments" do
      payment = FactoryGirl.create(:payment)
      other_payment = FactoryGirl.create(:payment)
      get :index, {}
      assigns(:payments).should eq([payment, other_payment])
    end
  end

end
