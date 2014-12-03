require 'spec_helper'

describe 'Creating adjustment payments' do
  # let!(:user) { FactoryGirl.create(:payment_admin) }
  let(:user) { FactoryGirl.create(:super_admin_user) }
  include_context 'user is logged in'
  include_context 'basic event configuration'

  describe "with an unpaid registration" do
    include_context 'unpaid registration'

    it "can create a payment" do
      competitor # load the competitor
      visit new_payment_adjustment_path
      select "#{competitor.with_id_to_s}", from: 'registrant_id'
      click_button "Start Payment Adjustment"
      expect(page).to have_content("Early Registration")
      click_button "Choose Items to Mark Paid"
      fill_in "payment_presenter_note", with: "Volunteer"
      check 'payment_presenter_unpaid_details_attributes_0_pay_for'
      click_button "Create and Save Payment"
      expect(competitor.reload.amount_owing).to eq(0)
      expect(competitor.amount_paid).to_not eq(0)
    end

    describe "with expense_items and details" do
      include_context 'unpaid registration'
      include_context 'optional expense_item with details'

      it "can create a payment" do
        visit new_payment_adjustment_path
        select "#{competitor.with_id_to_s}", from: 'registrant_id'
        click_button "Start Payment Adjustment"
        expect(page).to have_content("Early Registration")
        click_button "Choose Items to Mark Paid"
        fill_in "payment_presenter_note", with: "Volunteer"
        check 'payment_presenter_unpaid_details_attributes_0_pay_for'
        check 'payment_presenter_unpaid_details_attributes_1_pay_for'
        click_button "Create and Save Payment"
        expect(competitor.reload.amount_owing).to eq(0)
        expect(competitor.amount_paid).to_not eq(0)
      end
    end

    describe "with expense_items" do
      include_context 'unpaid registration'
      include_context 'optional expense_item'

      it "can create a payment" do
        visit new_payment_adjustment_path
        select "#{competitor.with_id_to_s}", from: 'registrant_id'
        click_button "Start Payment Adjustment"
        expect(page).to have_content("Early Registration")
        click_button "Choose Items to Mark Paid"
        fill_in "payment_presenter_note", with: "Volunteer"
        check 'payment_presenter_unpaid_details_attributes_0_pay_for'
        check 'payment_presenter_unpaid_details_attributes_1_pay_for'
        click_button "Create and Save Payment"
        expect(competitor.reload.amount_owing).to eq(0)
        expect(competitor.amount_paid).to_not eq(0)
      end
    end
  end

  describe "with a paid for element" do
    include_context 'unpaid registration'
    include_context 'paid expense item'

    it "can refund the item" do
      visit new_payment_adjustment_path
      select "#{competitor.with_id_to_s}", from: 'registrant_id'
      click_button "Start Payment Adjustment"
      expect(page).to have_content("T-Shirt")
      click_button "Refund some items"
      expect(page).to have_content("T-Shirt")
      fill_in "refund_presenter_note", with: "As per Hugo"
      fill_in "refund_presenter_percentage", with: "90"
      check "refund_presenter_paid_details_attributes_0_refund"
      click_button "Create Refund"
      expect(page).to have_content("As per Hugo")
    end
  end
end
