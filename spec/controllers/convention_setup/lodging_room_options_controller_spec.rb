require 'spec_helper'

describe ConventionSetup::LodgingRoomOptionsController do
  before do
    user = FactoryGirl.create(:convention_admin_user)
    sign_in user
  end

  # describe "GET new" do
  #   it "renders" do
  #     lodging = FactoryGirl.create(:lodging_room_type)
  #     get :new, params: { lodging_room_type_id: lodging_room_type.id }
  #     expect(response).to be_success
  #   end
  # end

  describe "GET edit" do
    it "shows the form" do
      lodging_room_option = FactoryGirl.create(:lodging_room_option)
      get :edit, params: { id: lodging_room_option.id }
      expect(response).to be_success

      assert_select "form", action: edit_convention_setup_lodging_room_option_path(lodging_room_option), method: "put" do
        assert_select "input#lodging_room_option_name", name: "lodging_room_option[name]"
      end
    end
  end

  describe "GET show" do
    let(:lodging_room_option) { FactoryGirl.create(:lodging_room_option) }
    let!(:lodging_day) { FactoryGirl.create(:lodging_day, lodging_room_option: lodging_room_option) }

    it "shows the lodging_room_option" do
      get :show, params: { id: lodging_room_option.id }
      expect(response).to be_success
    end
  end

  # describe "POST create" do
  #   describe "with valid params" do
  #     let(:lodging_room_type) { FactoryGirl.create(:lodging_room_type) }
  #     let(:valid_attributes) { FactoryGirl.attributes_for(:lodging_room_option) }

  #     it "creates a new Lodging" do
  #       expect do
  #         post :create, params: { lodging_room_type_id: lodging_room_type.id, lodging_room_option: valid_attributes }
  #       end.to change(LodgingRoomOption, :count).by(1)
  #     end
  #   end
  # end

  describe "PUT update" do
    let!(:lodging_room_option) { FactoryGirl.create(:lodging_room_option) }
    let(:new_valid_attributes) { FactoryGirl.attributes_for(:lodging_room_option) }

    it "updates the coupon code" do
      put :update, params: { id: lodging_room_option.to_param, lodging_room_option: new_valid_attributes }
      expect(lodging_room_option.reload.name).to eq(new_valid_attributes[:name])
    end
  end

  # describe "DELETE destroy" do
  #   let!(:lodging_room_option) { FactoryGirl.create(:lodging_room_option) }

  #   it "deletes the object" do
  #     expect do
  #       delete :destroy, params: { id: lodging_room_option.to_param }
  #     end.to change(LodgingRoomOption, :count).by(-1)
  #   end
  # end
end
