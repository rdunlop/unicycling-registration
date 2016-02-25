require 'spec_helper'

describe ExportPaymentsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  describe "GET list" do
    it "renders" do
      get :list
      expect(response).to be_success
    end
  end

  describe "PUT payments" do
    before do
      payment = FactoryGirl.create(:payment, :completed)
      FactoryGirl.create(:payment_detail, payment: payment)
    end

    it "can download the file" do
      put :payments
      expect(response).to be_success
    end
  end

  describe "PUT payment_details" do
    before do
      payment = FactoryGirl.create(:payment, :completed)
      FactoryGirl.create(:payment_detail, payment: payment)
    end

    it "can download the file" do
      put :payment_details
      expect(response).to be_success
    end
  end
end
