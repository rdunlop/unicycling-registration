require 'spec_helper'

describe Admin::RegFeesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:payment_admin)
    sign_in @admin_user
  end

  describe "GET index" do
    it "can view the index" do
      get :index
      expect(response).to be_success
    end
  end

  describe "POST change the reg fee" do
    before(:each) do
      @rp1 = FactoryGirl.create(:registration_cost, start_date: Date.new(2010, 1, 1), end_date: Date.new(2012, 1, 1))
      @rp2 = FactoryGirl.create(:registration_cost, start_date: Date.new(2012, 1, 2), end_date: Date.new(2020, 2, 2))
      @reg = FactoryGirl.create(:competitor)
    end

    it "initially has a reg fee from rp2" do
      expect(@reg.owing_expense_items.count).to eq(1)
      expect(@reg.owing_expense_items.first).to eq(@rp2.expense_item)
    end

    it "can be changed to a different reg period" do
      post :update_reg_fee, reg_fee: {registrant_id: @reg.id, registration_cost_id: @rp1.id }
      expect(response).to redirect_to set_reg_fees_path
      @reg.reload
      expect(@reg.owing_expense_items.count).to eq(1)
      expect(@reg.owing_expense_items.first).to eq(@rp1.expense_item)
      expect(@reg.registrant_expense_items.first.locked).to eq(true)
    end

    it "can change to a different reg fee twice" do
      post :update_reg_fee, reg_fee: {registrant_id: @reg.id, registration_cost_id: @rp1.id }
      post :update_reg_fee, reg_fee: {registrant_id: @reg.id, registration_cost_id: @rp2.id }
      @reg.reload
      expect(@reg.owing_expense_items.count).to eq(1)
      expect(@reg.owing_expense_items.first).to eq(@rp2.expense_item)
      expect(@reg.registrant_expense_items.first.locked).to eq(true)
    end

    it "cannot be updated if the registrant is already paid" do
      payment = FactoryGirl.create(:payment)
      FactoryGirl.create(:payment_detail, registrant: @reg, expense_item: @reg.registrant_expense_items.first.expense_item, payment: payment)
      payment.completed = true
      payment.save
      @reg.reload
      post :update_reg_fee, reg_fee: {registrant_id: @reg.id, registration_cost_id: @rp1.id }
      expect(response).to render_template("index")
    end
  end
end
