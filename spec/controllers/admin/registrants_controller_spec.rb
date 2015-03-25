require 'spec_helper'

describe Admin::RegistrantsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "with an admin user" do
    before(:each) do
      sign_out @user
      @admin_user = FactoryGirl.create(:admin_user)
      sign_in @admin_user
    end

    describe "GET manage_all" do
      it "assigns all registrants as @registrants" do
        registrant = FactoryGirl.create(:competitor)
        other_reg = FactoryGirl.create(:registrant)
        get :manage_all, {}
        expect(assigns(:registrants)).to match_array([registrant, other_reg])
      end
    end

    describe "POST undelete" do
      before(:each) do
        FactoryGirl.create(:registration_period)
      end
      it "un-deletes a deleted registration" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.to_param }
        registrant.reload
        expect(registrant.deleted).to eq(false)
      end

      it "redirects to the root" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.to_param }
        expect(response).to redirect_to(manage_all_registrants_path)
      end

      describe "as a normal user" do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user
        end
        it "Cannot undelete a user" do
          registrant = FactoryGirl.create(:competitor, :deleted => true)
          post :undelete, {:id => registrant.to_param }
          registrant.reload
          expect(registrant.deleted).to eq(true)
        end
      end
    end

    describe "PUT change the reg fee" do
      before(:each) do
        @rp1 = FactoryGirl.create(:registration_period, :start_date => Date.new(2010, 01, 01), :end_date => Date.new(2012, 01, 01))
        @rp2 = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 01, 02), :end_date => Date.new(2020, 02, 02))
        @reg = FactoryGirl.create(:competitor)
      end

      it "initially has a reg fee from rp2" do
        expect(@reg.owing_expense_items.count).to eq(1)
        expect(@reg.owing_expense_items.first).to eq(@rp2.competitor_expense_item)
      end

      it "can be changed to a different reg period" do
        put :update_reg_fee, {:id => @reg.to_param, :registration_period_id => @rp1.id }
        expect(response).to redirect_to reg_fee_registrant_path(@reg)
        @reg.reload
        expect(@reg.owing_expense_items.count).to eq(1)
        expect(@reg.owing_expense_items.first).to eq(@rp1.competitor_expense_item)
        expect(@reg.registrant_expense_items.first.locked).to eq(true)
      end
      it "cannot be updated if the registrant is already paid" do
        payment = FactoryGirl.create(:payment)
        pd = FactoryGirl.create(:payment_detail, :registrant => @reg, :expense_item => @reg.registrant_expense_items.first.expense_item, :payment => payment)
        payment.completed = true
        payment.save
        @reg.reload
        put :update_reg_fee, {:id => @reg.to_param, :registration_period_id => @rp1.id }
        expect(response).to render_template("reg_fee")
      end
    end
  end
end
