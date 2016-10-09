require 'spec_helper'

describe ConventionSetup::CategoriesController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Category. As you add validations to Category, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "something"
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read categories" do
      get :index
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "shows all categories" do
      category = Category.create! valid_attributes
      get :index
      assert_select "tr>td", text: category.to_s, count: 1

      assert_select "h1", "Event Categories"
    end
  end

  describe "GET edit" do
    it "shows the requested category" do
      category = Category.create! valid_attributes
      get :edit, params: { id: category.to_param }
      assert_select "form", action: convention_setup_categories_path(category), method: "post" do
        assert_select "input#category_info_url", name: "category[info_url]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Category" do
        expect do
          post :create, params: { category: valid_attributes }
        end.to change(Category, :count).by(1)
      end

      it "redirects to the created category" do
        post :create, params: { category: valid_attributes }
        expect(response).to redirect_to(convention_setup_categories_path)
      end
    end

    describe "with invalid params" do
      it "does not update a newly created category" do
        # Trigger the behavior that occurs when invalid params are submitted
        category = Category.create! valid_attributes
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        expect do
          post :create, params: { category: {name: "Hi"} }
        end.not_to change { category.reload.name }
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        post :create, params: { category: {name: "Hi"} }

        assert_select "h1", "Event Categories"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested category" do
        category = Category.create! valid_attributes
        expect do
          put :update, params: { id: category.to_param, category: valid_attributes.merge(name: "New name") }
        end.to change { category.reload.name }
      end

      it "redirects to the category" do
        category = Category.create! valid_attributes
        put :update, params: { id: category.to_param, category: valid_attributes }
        expect(response).to redirect_to(convention_setup_categories_path)
      end
    end

    describe "with invalid params" do
      it "does not update the category" do
        category = Category.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: category.to_param, category: {name: 'fake'} }
        end.not_to change { category.reload.name }
      end

      it "re-renders the 'edit' template" do
        category = Category.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        put :update, params: { id: category.to_param, category: {name: "Hi"} }

        assert_select "h1", "Editing Event Category"
      end
    end
  end

  describe "PUT update_row_order" do
    let!(:category_1) { FactoryGirl.create(:category) }
    let!(:category_2) { FactoryGirl.create(:category) }

    it "updates the order" do
      put :update_row_order, params: { id: category_1.to_param, row_order_position: 1 }
      expect(category_2.reload.position).to eq(1)
      expect(category_1.reload.position).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested category" do
      category = Category.create! valid_attributes
      expect do
        delete :destroy, params: { id: category.to_param }
      end.to change(Category, :count).by(-1)
    end

    it "redirects to the categories list" do
      category = Category.create! valid_attributes
      delete :destroy, params: { id: category.to_param }
      expect(response).to redirect_to(convention_setup_categories_url)
    end
  end
end
