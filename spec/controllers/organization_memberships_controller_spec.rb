# == Schema Information
#
# Table name: organization_memberships
#
#  id                   :bigint(8)        not null, primary key
#  registrant_id        :bigint(8)
#  manual_member_number :string
#  system_member_number :string
#  manually_confirmed   :boolean          default(FALSE), not null
#  system_confirmed     :boolean          default(FALSE), not null
#  system_status        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_organization_memberships_on_registrant_id  (registrant_id)
#

require 'spec_helper'

describe OrganizationMembershipsController do
  let(:user) { FactoryBot.create(:super_admin_user) }
  before do
    @config = FactoryBot.create(:event_configuration, :with_usa)
    sign_in user

    FactoryBot.create_list(:competitor, 5)
  end

  let(:registrant) { FactoryBot.create(:registrant) }
  let(:organization_membership) { registrant.organization_membership }

  describe "#index" do
    it "can list all members" do
      get :index
      expect(response).to be_success
    end
  end

  describe "#toggle_confirm" do
    context "when the user is not yet confirmed" do
      it "can confirm" do
        put :toggle_confirm, params: { id: registrant.id }
        expect(registrant.reload.organization_membership).to be_manually_confirmed
      end
      it "can confirm with JS" do
        put :toggle_confirm, params: { id: registrant.id, format: :js }
        expect(registrant.reload.organization_membership).to be_manually_confirmed
      end
    end

    context "when the user is a confirmed member" do
      before { organization_membership.update_attribute(:manually_confirmed, true) }

      it "can unconfirm" do
        put :toggle_confirm, params: { id: registrant.id }
        expect(registrant.reload.organization_membership).not_to be_manually_confirmed
      end
    end
  end

  describe "#update_number" do
    let(:new_member_number) { "10" }

    it "saves the membership number" do
      put :update_number, params: { id: registrant.id, membership_number: new_member_number }, format: :js
      expect(registrant.reload.organization_membership.manual_member_number).to eq new_member_number
    end
  end

  describe "#export" do
    it "outputs some rows" do
      get :export, format: 'xls'
      expect(response.content_type.to_s).to eq("application/vnd.ms-excel")
    end
  end

  describe "#refresh_usa_status" do
    it "returns success" do
      allow_any_instance_of(UsaMembershipChecker).to receive(:current_member?).and_return(true)
      post :refresh_usa_status, params: { id: registrant.id, format: :js }
      expect(response).to be_success
    end
  end
end
