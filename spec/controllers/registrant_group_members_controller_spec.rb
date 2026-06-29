# == Schema Information
#
# Table name: registrant_group_members
#
#  id                      :integer          not null, primary key
#  registrant_id           :integer
#  registrant_group_id     :integer
#  created_at              :datetime
#  updated_at              :datetime
#  additional_details_type :string
#  additional_details_id   :integer
#
# Indexes
#
#  index_registrant_group_mumbers_registrant_group_id  (registrant_group_id)
#  index_registrant_group_mumbers_registrant_id        (registrant_id)
#  reg_group_reg_group                                 (registrant_id,registrant_group_id) UNIQUE
#

require 'spec_helper'

describe RegistrantGroupMembersController do
  before do
    @admin_user = FactoryBot.create(:super_admin_user)
    sign_in @admin_user
  end

  let(:registrant_group) { FactoryBot.create(:registrant_group) }

  describe "POST create" do
    describe "with valid params" do
      let(:params) do
        [
          FactoryBot.create(:competitor).id
        ]
      end

      it "creates a new record" do
        expect do
          post :create, params: { registrant_ids: params, registrant_group_id: registrant_group.to_param }
        end.to change(RegistrantGroupMember, :count).by(1)
      end
    end

    describe "when registrant_ids is nil (no selection made)" do
      it "does not crash" do
        expect do
          post :create, params: { registrant_group_id: registrant_group.to_param }
        end.not_to raise_error
      end

      it "creates no records" do
        expect do
          post :create, params: { registrant_group_id: registrant_group.to_param }
        end.not_to change(RegistrantGroupMember, :count)
      end
    end

    describe "when registrant_ids contains a blank entry (Rails hidden field)" do
      let(:registrant) { FactoryBot.create(:competitor) }

      it "does not crash" do
        expect do
          post :create, params: { registrant_ids: ["", registrant.id], registrant_group_id: registrant_group.to_param }
        end.not_to raise_error
      end

      it "creates only the valid record" do
        expect do
          post :create, params: { registrant_ids: ["", registrant.id], registrant_group_id: registrant_group.to_param }
        end.to change(RegistrantGroupMember, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    let!(:registrant_group_member) { FactoryBot.create(:registrant_group_member, registrant_group: registrant_group) }

    it "destroys the requested registrant_group_member" do
      expect do
        delete :destroy, params: { id: registrant_group_member.to_param }
      end.to change(RegistrantGroupMember, :count).by(-1)
    end

    it "redirects to the registrant_group list" do
      delete :destroy, params: { id: registrant_group_member.to_param }
      expect(response).to redirect_to(registrant_group_path(registrant_group))
    end
  end
end
