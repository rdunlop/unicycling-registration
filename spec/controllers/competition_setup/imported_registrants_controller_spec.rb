require 'spec_helper'

describe CompetitionSetup::ImportedRegistrantsController do
  before do
    sign_in FactoryBot.create(:super_admin_user)
  end

  describe "POST upload" do
    context "when no file is submitted" do
      it "redirects back with an alert instead of raising" do
        expect do
          post :upload, params: {}
        end.not_to change(ImportedRegistrant, :count)

        expect(response).to redirect_to(imported_registrants_path)
        expect(flash[:alert]).to eq("Please choose a file to upload")
      end
    end
  end
end
