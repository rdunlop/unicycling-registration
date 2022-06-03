require 'spec_helper'

describe Admin::MedicalCertificatesController do
  before do
    @user = FactoryBot.create(:super_admin_user)
    sign_in @user
  end

  describe "GET #index" do
    let!(:registrant) { FactoryBot.create_list(:registrant, 10, :with_medical_certificate_pdf) }

    it "renders the page" do
      get :index
    end
  end
end
