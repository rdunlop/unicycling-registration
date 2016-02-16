require 'spec_helper'

describe OrganizationMembershipsController do
  let(:user) { FactoryGirl.create(:super_admin_user) }
  before(:each) do
    @config = FactoryGirl.create(:event_configuration, :with_usa)
    sign_in user

    FactoryGirl.create_list(:competitor, 5)
  end

  let(:registrant) { FactoryGirl.create(:registrant) }
  let(:contact_detail) { registrant.contact_detail }

  describe "#index" do
    it "can list all members" do
      get :index
      expect(response).to be_success
    end
  end

  describe "#toggle_confirm" do
    context "when the user is not yet confirmed" do
      it "can confirm" do
        put :toggle_confirm, id: registrant.id
        expect(registrant.reload.contact_detail).to be_organization_membership_manually_confirmed
      end
      it "can confirm with JS" do
        put :toggle_confirm, id: registrant.id, format: :js
        expect(registrant.reload.contact_detail).to be_organization_membership_manually_confirmed
      end
    end

    context "when the user is a confirmed member" do
      before { contact_detail.update_attribute(:organization_membership_manually_confirmed, true) }

      it "can unconfirm" do
        put :toggle_confirm, id: registrant.id
        expect(registrant.reload.contact_detail).not_to be_organization_membership_manually_confirmed
      end
    end
  end

  describe "#update_number" do
    let(:new_member_number) { "10" }

    it "saves the membership number" do
      put :update_number, id: registrant.id, membership_number: new_member_number, format: :js
      expect(registrant.reload.contact_detail.organization_member_number).to eq new_member_number
    end
  end

  describe "#export" do
    it "outputs some rows" do
      get :export, format: 'xls'
      expect(assigns(:headers)).to include("ID")
      expect(assigns(:headers)).to include("Organization Membership#")
      expect(assigns(:rows).count).to eq(5)
    end
  end
end
