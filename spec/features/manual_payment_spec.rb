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
      click_button "Start Payment Adjustment"
      expect(page).to have_content("Early Registration")
      fill_in "manual_payment_note", with: "Volunteer"
      check 'manual_payment_unpaid_details_attributes_0_pay_for'
      click_button "Mark elements Received"
      expect(competitor.reload.amount_owing).to eq(0)
      expect(competitor.amount_paid).to_not eq(0)
    end
  end
end
