require "spec_helper"
require "request_helper"

RSpec.describe "/rails_admin", type: :request do
  context "as a super_admin" do
    let(:user) { FactoryBot.create(:super_admin_user) }
    before { login(user) }

    it "can browse" do
      get "/rails_admin"
      expect(response).to be_successful
    end
  end
end
