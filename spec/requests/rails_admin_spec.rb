require "spec_helper"
require "request_helper"

RSpec.describe "/admin", type: :request do
  context "as a super_admin" do
    let(:user) { FactoryBot.create(:super_admin_user) }

    before { login(user) }

    it "can browse" do
      get "/admin/resources/competitions"
      expect(response).to be_successful
    end
  end
end
