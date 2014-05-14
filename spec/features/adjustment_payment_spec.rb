require 'spec_helper'

shared_context "unpaid registration" do
  before :each do
    @competitor = FactoryGirl.create(:competitor)
  end
end


shared_context 'optional expense_item' do
  before :each do
    @ei = FactoryGirl.create(:expense_item, name: "USA Individual Membership", has_details: false, cost: 15)
    @competitor.registrant_expense_items.create expense_item: @ei, system_managed: false, details: nil
    @competitor.reload
  end
end

shared_context 'optional expense_item with details' do
  before :each do
    @ei = FactoryGirl.create(:expense_item, name: "USA Family Membership", has_details: true, cost: 15)
    @competitor.registrant_expense_items.create expense_item: @ei, system_managed: false, details: ""
    @competitor.reload
  end
end

describe 'Creating adjustment payments' do
  #let!(:user) { FactoryGirl.create(:payment_admin) }
  let(:user) { FactoryGirl.create(:super_admin_user) }
  include_context 'user is logged in'
  include_context 'basic event configuration'

  describe "with an unpaid registration" do
    include_context 'unpaid registration'

    it "can create a payment" do
      visit new_payment_adjustment_path
      select "#{@competitor.with_id_to_s}", from: 'registrant_id'
      click_button "Start Payment Adjustment"
      expect(page).to have_content("Early Registration")
      click_button "Choose Items to Mark Paid"
      fill_in "payment_presenter_note", with: "Volunteer"
      check 'payment_presenter_unpaid_details_attributes_0_pay_for'
      click_button "Create and Save Payment"
      expect(@competitor.reload.amount_owing).to eq(0)
      expect(@competitor.amount_paid).to_not eq(0)
    end

    describe "with expense_items and details" do
      include_context 'unpaid registration'
      include_context 'optional expense_item with details'

      it "can create a payment" do
        visit new_payment_adjustment_path
        select "#{@competitor.with_id_to_s}", from: 'registrant_id'
        click_button "Start Payment Adjustment"
        expect(page).to have_content("Early Registration")
        click_button "Choose Items to Mark Paid"
        fill_in "payment_presenter_note", with: "Volunteer"
        check 'payment_presenter_unpaid_details_attributes_0_pay_for'
        check 'payment_presenter_unpaid_details_attributes_1_pay_for'
        click_button "Create and Save Payment"
        expect(@competitor.reload.amount_owing).to eq(0)
        expect(@competitor.amount_paid).to_not eq(0)
      end
    end

    describe "with expense_items" do
      include_context 'unpaid registration'
      include_context 'optional expense_item'

      it "can create a payment" do
        visit new_payment_adjustment_path
        select "#{@competitor.with_id_to_s}", from: 'registrant_id'
        click_button "Start Payment Adjustment"
        expect(page).to have_content("Early Registration")
        click_button "Choose Items to Mark Paid"
        fill_in "payment_presenter_note", with: "Volunteer"
        check 'payment_presenter_unpaid_details_attributes_0_pay_for'
        check 'payment_presenter_unpaid_details_attributes_1_pay_for'
        click_button "Create and Save Payment"
        expect(@competitor.reload.amount_owing).to eq(0)
        expect(@competitor.amount_paid).to_not eq(0)
      end
    end
  end
end
