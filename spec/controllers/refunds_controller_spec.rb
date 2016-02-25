require 'spec_helper'

describe RefundsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end

  let(:refund) { FactoryGirl.create(:refund) }

  describe "GET show" do
    it "renders" do
      get :show, id: refund.id
      expect(response).to be_success
    end
  end
end
