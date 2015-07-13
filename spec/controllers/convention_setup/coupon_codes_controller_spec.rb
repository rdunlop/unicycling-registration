require 'spec_helper'

describe ConventionSetup::CouponCodesController do
  before do
    user = FactoryGirl.create(:convention_admin_user)
    sign_in user
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read summary" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all coupon_codes as @coupon_codes" do
      coupon_code = FactoryGirl.create(:coupon_code)
      get :index, {}
      expect(response).to be_success
      expect(assigns(:coupon_codes)).to eq([coupon_code])
    end
  end

  describe "GET edit" do
    it "assigns coupon_code as @coupon_code" do
      coupon_code = FactoryGirl.create(:coupon_code)
      get :edit, id: coupon_code.id
      expect(response).to be_success
      expect(assigns(:coupon_code)).to eq(coupon_code)
    end
  end
end
