require 'spec_helper'

describe ConventionSetup::LodgingsController do
  before do
    user = FactoryGirl.create(:convention_admin_user)
    sign_in user
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read summary" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "shows all lodgings" do
      lodging = FactoryGirl.create(:lodging)
      get :index
      expect(response).to be_success

      assert_select "td", lodging.name
    end
  end

  describe "GET new" do
    it "renders" do
      get :new
      expect(response).to be_success
    end
  end

  describe "GET edit" do
    it "shows the lodging form" do
      lodging = FactoryGirl.create(:lodging)
      get :edit, params: { id: lodging.id }
      expect(response).to be_success

      assert_select "form", action: edit_convention_setup_lodging_path(lodging), method: "put" do
        assert_select "input#lodging_name", name: "lodging[name]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:valid_attributes) { FactoryGirl.attributes_for(:lodging) }

      it "creates a new Lodging" do
        expect do
          post :create, params: { lodging: valid_attributes }
        end.to change(Lodging, :count).by(1)
      end
    end
  end

  describe "GET show" do
    let(:lodging) { FactoryGirl.create(:lodging) }
    let!(:lodging_room_type) { FactoryGirl.create(:lodging_room_type, lodging: lodging) }

    it "shows the lodging" do
      get :show, params: { id: lodging.id }
      expect(response).to be_success
    end
  end

  describe "PUT update" do
    let!(:lodging) { FactoryGirl.create(:lodging) }
    let(:new_valid_attributes) { FactoryGirl.attributes_for(:lodging) }

    it "updates the coupon code" do
      put :update, params: { id: lodging.to_param, lodging: new_valid_attributes }
      expect(lodging.reload.name).to eq(new_valid_attributes[:name])
    end
  end

  describe "DELETE destroy" do
    let!(:lodging) { FactoryGirl.create(:lodging) }

    it "deletes the object" do
      expect do
        delete :destroy, params: { id: lodging.to_param }
      end.to change(Lodging, :count).by(-1)
    end
  end
end
