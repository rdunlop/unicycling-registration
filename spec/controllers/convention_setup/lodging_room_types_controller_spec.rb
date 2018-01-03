require 'spec_helper'

describe ConventionSetup::LodgingRoomTypesController do
  before do
    user = FactoryGirl.create(:convention_admin_user)
    sign_in user
  end

  # describe "GET new" do
  #   it "renders" do
  #     lodging = FactoryGirl.create(:lodging)
  #     get :new, params: { lodging_id: lodging.id }
  #     expect(response).to be_success
  #   end
  # end

  describe "GET edit" do
    it "shows the lodging form" do
      lodging_room_type = FactoryGirl.create(:lodging_room_type)
      get :edit, params: { id: lodging_room_type.id }
      expect(response).to be_success

      assert_select "form", action: edit_convention_setup_lodging_room_type_path(lodging_room_type), method: "put" do
        assert_select "input#lodging_room_type_name", name: "lodging_room_type[name]"
      end
    end
  end

  describe "GET show" do
    let(:lodging_room_type) { FactoryGirl.create(:lodging_room_type) }
    let!(:lodging_room_option) { FactoryGirl.create(:lodging_room_option, lodging_room_type: lodging_room_type) }

    it "shows the lodging_room_type" do
      get :show, params: { id: lodging_room_type.id }
      expect(response).to be_success
    end
  end

  # describe "POST create" do
  #   describe "with valid params" do
  #     let(:lodging) { FactoryGirl.create(:lodging) }
  #     let(:valid_attributes) { FactoryGirl.attributes_for(:lodging_room_type) }

  #     it "creates a new Lodging" do
  #       expect do
  #         post :create, params: { lodging_id: lodging.id, lodging_room_type: valid_attributes }
  #       end.to change(LodgingRoomType, :count).by(1)
  #     end
  #   end
  # end

  describe "PUT update" do
    let!(:lodging_room_type) { FactoryGirl.create(:lodging_room_type) }
    let(:new_valid_attributes) { FactoryGirl.attributes_for(:lodging_room_type) }

    it "updates the coupon code" do
      put :update, params: { id: lodging_room_type.to_param, lodging_room_type: new_valid_attributes }
      expect(lodging_room_type.reload.name).to eq(new_valid_attributes[:name])
    end
  end

  # describe "DELETE destroy" do
  #   let!(:lodging_room_type) { FactoryGirl.create(:lodging_room_type) }

  #   it "deletes the object" do
  #     expect do
  #       delete :destroy, params: { id: lodging_room_type.to_param }
  #     end.to change(LodgingRoomType, :count).by(-1)
  #   end
  # end
end
