# == Schema Information
#
# Table name: registrant_groups
#
#  id                       :integer          not null, primary key
#  name                     :string
#  created_at               :datetime
#  updated_at               :datetime
#  registrant_group_type_id :integer
#
# Indexes
#
#  index_registrant_groups_on_registrant_group_type_id  (registrant_group_type_id)
#

require 'spec_helper'

describe RegistrantGroupsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end

  # This should return the minimal set of attributes required to create a valid
  # RegistrantGroup. As you add validations to RegistrantGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { name: "MyString" }
  end

  describe "GET index" do
    it "shows all registrant_groups" do
      registrant_group = RegistrantGroup.create! valid_attributes
      get :index
      assert_select "tr>td", text: registrant_group.name.to_s, count: 1
    end
  end

  describe "GET show" do
    it "shows the requested registrant_group" do
      registrant_group = RegistrantGroup.create! valid_attributes
      get :show, params: { id: registrant_group.to_param }
      assert_match(/#{registrant_group.name}/, response.body)
    end
  end

  describe "GET edit" do
    it "shows the requested registrant_group form" do
      registrant_group = RegistrantGroup.create! valid_attributes
      get :edit, params: { id: registrant_group.to_param }

      assert_select "form", action: registrant_groups_path(registrant_group), method: "post" do
        assert_select "input#registrant_group_name", name: "registrant_group[name]"
        assert_select "select#registrant_group_registrant_id", name: "registrant_group[registrant_id]"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the registrant_group" do
        registrant_group = RegistrantGroup.create! valid_attributes
        expect do
          put :update, params: { id: registrant_group.to_param, registrant_group: valid_attributes.merge(name: "Hi There") }
        end.to change { registrant_group.reload.name }
      end

      it "redirects to the registrant_group" do
        registrant_group = RegistrantGroup.create! valid_attributes
        put :update, params: { id: registrant_group.to_param, registrant_group: valid_attributes }
        expect(response).to redirect_to(registrant_group)
      end
    end

    describe "with invalid params" do
      let!(:existing_reg_group) { FactoryGirl.create(:registrant_group)}
      it "does not update the registrant_group" do
        registrant_group = FactoryGirl.create(:registrant_group, registrant_group_type: existing_reg_group.registrant_group_type)
        # Trigger the behavior that occurs when invalid params are submitted
        expect do
          put :update, params: { id: registrant_group.to_param, registrant_group: { name: existing_reg_group.name } }
        end.not_to change { registrant_group.reload.name }
      end

      it "re-renders the 'edit' template" do
        registrant_group = FactoryGirl.create(:registrant_group, registrant_group_type: existing_reg_group.registrant_group_type)
        put :update, params: { id: registrant_group.to_param, registrant_group: { name: existing_reg_group.name } }
        assert_select "h1", "Edit Registrant Group"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registrant_group" do
      registrant_group = RegistrantGroup.create! valid_attributes
      expect do
        delete :destroy, params: { id: registrant_group.to_param }
      end.to change(RegistrantGroup, :count).by(-1)
    end

    it "redirects to the registrant_groups list" do
      registrant_group = RegistrantGroup.create! valid_attributes
      delete :destroy, params: { id: registrant_group.to_param }
      expect(response).to redirect_to(registrant_groups_url)
    end
  end
end
