# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe RegistrantGroupTypesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end

  describe "GET index" do
    it "shows all registrant_group_types" do
      registrant_group_type = FactoryGirl.create(:registrant_group_type)
      get :index
      assert_select "tr>td", text: registrant_group_type.source_element.to_s, count: 1
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:params) do
        {
          notes: "Some Notes",
          max_members_per_group: "10"
        }
      end

      context "for an event" do
        let(:event) { FactoryGirl.create(:event) }

        it "creates a new RegistrantGroupType" do
          expect do
            post :create, params: { registrant_group_type: params, source_element_event: event.id }
          end.to change(RegistrantGroupType, :count).by(1)
        end
      end

      context "for an expense item" do
        let(:expense_item) { FactoryGirl.create(:expense_item) }

        it "creates a new RegistrantGroupType" do
          expect do
            post :create, params: { registrant_group_type: params, source_element_expense_item: expense_item.id }
          end.to change(RegistrantGroupType, :count).by(1)
        end
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registrant_group_type" do
      registrant_group_type = FactoryGirl.create(:registrant_group_type)
      expect do
        delete :destroy, params: { id: registrant_group_type.to_param }
      end.to change(RegistrantGroupType, :count).by(-1)
    end
  end

  describe "GET show" do
    let(:registrant_group_type) { FactoryGirl.create(:registrant_group_type) }

    it "succeeds" do
      get :show, params: { id: registrant_group_type.to_param }
      expect(response).to be_success
    end
  end

  describe "GET edit" do
    let(:registrant_group_type) { FactoryGirl.create(:registrant_group_type) }

    it "succeeds" do
      get :edit, params: { id: registrant_group_type.to_param }
      expect(response).to be_success
    end
  end
end
