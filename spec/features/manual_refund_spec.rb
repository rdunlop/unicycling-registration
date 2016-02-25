require 'spec_helper'

describe 'Creating refund' do
  let(:user) { FactoryGirl.create(:payment_admin) }
  include_context 'user is logged in'
  include_context 'basic event configuration'

  describe "with a paid for element" do
    include_context 'unpaid registration'
    include_context 'paid expense item'

    it "can refund the item" do
      visit new_manual_refund_path
      select competitor.with_id_to_s.to_s, from: 'registrant_ids'
      click_button "Next Step (choose items)"
      expect(page).to have_content("T-Shirt")
      fill_in "manual_refund_note", with: "As per Hugo"
      fill_in "manual_refund_percentage", with: "90"
      check "manual_refund_items_attributes_0_refund"
      click_button "Create Refund"
      expect(page).to have_content("Successfully created refund")
    end
  end
end
