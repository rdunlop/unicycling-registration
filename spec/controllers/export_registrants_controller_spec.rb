require 'spec_helper'

describe ExportRegistrantsController do
  let!(:registrant) { FactoryBot.create(:registrant) }

  before do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end

  describe "#download_payment_dates" do
    let!(:payment) { FactoryBot.create(:payment, :completed) }
    let!(:payment_detail) { FactoryBot.create(:payment_detail, registrant: registrant, payment: payment) }

    it "renders" do
      get :download_payment_dates
      expect(response).to be_successful
    end
  end

  describe "#download_all" do
    it "renders" do
      get :download_all
      expect(response).to be_successful
    end
  end

  describe "#download_with_payment_details" do
    it "renders" do
      get :download_with_payment_details
      expect(response).to be_successful
    end
  end
end
