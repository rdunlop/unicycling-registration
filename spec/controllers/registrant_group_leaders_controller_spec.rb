# == Schema Information
#
# Table name: registrant_group_leaders
#
#  id                  :integer          not null, primary key
#  registrant_group_id :integer          not null
#  user_id             :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_registrant_group_leaders_on_registrant_group_id  (registrant_group_id)
#  index_registrant_group_leaders_on_user_id              (user_id)
#  registrant_group_leaders_uniq                          (registrant_group_id,user_id) UNIQUE
#

require 'spec_helper'

describe RegistrantGroupLeadersController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end

  let(:registrant_group) { FactoryGirl.create(:registrant_group) }

  describe "POST create" do
    describe "with valid params" do
      let(:params) do
        {
          user_id: FactoryGirl.create(:user).id
        }
      end

      it "creates a new record" do
        expect do
          post :create, params: { registrant_group_leader: params, registrant_group_id: registrant_group.to_param }
        end.to change(RegistrantGroupLeader, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    let!(:other_registrant_group_leader) { FactoryGirl.create(:registrant_group_leader, registrant_group: registrant_group) }
    let!(:registrant_group_leader) { FactoryGirl.create(:registrant_group_leader, registrant_group: registrant_group) }
    it "destroys the requested registrant_group_leader" do
      expect do
        delete :destroy, params: { id: registrant_group_leader.to_param }
      end.to change(RegistrantGroupLeader, :count).by(-1)
    end

    it "redirects to the registrant_group list" do
      delete :destroy, params: { id: registrant_group_leader.to_param }
      expect(response).to redirect_to(registrant_group_path(registrant_group))
    end
  end
end
