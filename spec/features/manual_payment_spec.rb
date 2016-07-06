require 'spec_helper'

describe 'Creating manual payments' do
  let(:user) { FactoryGirl.create(:payment_admin) }
  include_context 'user is logged in'
  include_context 'basic event configuration'

  describe "with an unpaid registration" do
    include_context 'unpaid registration'

    it "can create a payment" do
      competitor # load the competitor
      visit new_manual_payment_path
      select competitor.with_id_to_s.to_s, from: 'registrant_ids'
      click_button "Next Step (choose items)"
      expect(page).to have_content("Early Registration")
      check 'manual_payment_unpaid_details_attributes_0_pay_for'
      click_button "Create Payment Record"
      click_link "Mark as Paid (admin function)"
      fill_in "payment_note", with: "Volunteer"
      click_button "Mark as Paid (admin function)"
      expect(competitor.reload.amount_owing).to eq(0.to_money)
      expect(competitor.amount_paid).to_not eq(0.to_money)
    end
  end
end
