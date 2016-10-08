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
      get :index
      expect(response).to be_success
      expect(assigns(:coupon_codes)).to eq([coupon_code])
    end
  end

  describe "GET edit" do
    it "assigns coupon_code as @coupon_code" do
      coupon_code = FactoryGirl.create(:coupon_code)
      get :edit, params: { id: coupon_code.id }
      expect(response).to be_success
      expect(assigns(:coupon_code)).to eq(coupon_code)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:valid_attributes) { FactoryGirl.attributes_for(:coupon_code) }

      it "creates a new CouponCode" do
        expect do
          post :create, params: { coupon_code: valid_attributes }
        end.to change(CouponCode, :count).by(1)
      end
    end
  end

  describe "PUT update" do
    let!(:coupon_code) { FactoryGirl.create(:coupon_code) }
    let(:new_valid_attributes) { FactoryGirl.attributes_for(:coupon_code) }

    it "updates the coupon code" do
      put :update, params: { id: coupon_code.to_param, coupon_code: new_valid_attributes }
      expect(coupon_code.reload.name).to eq(new_valid_attributes[:name])
    end
  end

  describe "DELETE destroy" do
    let!(:coupon_code) { FactoryGirl.create(:coupon_code) }

    it "deletes the object" do
      expect do
        delete :destroy, params: { id: coupon_code.to_param }
      end.to change(CouponCode, :count).by(-1)
    end
  end
end
