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
#  index_registrant_group_members_on_registrant_group_id  (registrant_group_id)
#  index_registrant_group_members_on_registrant_id        (registrant_id)
#  reg_group_reg_group                                    (registrant_id,registrant_group_id) UNIQUE
#

require 'spec_helper'

describe RegistrantGroupMembersController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end

  let(:registrant_group) { FactoryGirl.create(:registrant_group) }

  describe "POST create" do
    describe "with valid params" do
      let(:params) do
        {
          registrant_id: FactoryGirl.create(:competitor).id
        }
      end

      it "creates a new record" do
        expect do
          post :create, params: { registrant_group_member: params, registrant_group_id: registrant_group.to_param }
        end.to change(RegistrantGroupMember, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    let!(:registrant_group_member) { FactoryGirl.create(:registrant_group_member, registrant_group: registrant_group) }
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
