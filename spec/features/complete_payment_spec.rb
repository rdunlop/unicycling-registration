require 'spec_helper'

describe 'Completing normal payments' do
  # let!(:user) { FactoryGirl.create(:payment_admin) }
  let(:user) { FactoryGirl.create(:user) }
  include_context 'user is logged in'
  include_context 'unpaid registration'
  include_context 'basic event configuration', test_mode: true

  describe "with an unpaid registration" do
    before :each do
      competitor # load comp
    end

    it "can create a payment" do
      visit new_payment_path
      expect(page).to have_content("Registration")
      expect(page).to have_content("$20.00")
      click_button "Start Payment"
      click_link "Pretend to pay by credit card"
      expect(competitor.reload.amount_owing).to eq(0.to_money)
    end

    describe "with expense_items and details" do
      include_context 'optional expense_item with details', cost: 5

      it "can create a payment" do
        visit new_payment_path
        expect(page).to have_content("Registration")
        expect(page).to have_content("$20.00")
        expect(page).to have_content("$5.00")
        click_button "Start Payment"
        click_link "Pretend to pay by credit card"
        expect(competitor.reload.amount_owing).to eq(0.to_money)
      end
    end

    describe "with expense_items" do
      include_context 'optional expense_item', cost: 7

      it "can create a payment" do
        visit new_payment_path
        expect(page).to have_content("Registration")
        expect(page).to have_content("$20.00")
        expect(page).to have_content("$7.00")
        click_button "Start Payment"
        click_link "Pretend to pay by credit card"
        expect(competitor.reload.amount_owing).to eq(0.to_money)
      end
    end
  end
end
