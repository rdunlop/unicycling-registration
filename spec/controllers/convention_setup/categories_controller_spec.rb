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
    it "assigns all categories as @categories" do
      category = Category.create! valid_attributes
      get :index, {}
      expect(assigns(:categories)).to eq([category])
      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe "GET edit" do
    it "assigns the requested category as @category" do
      category = Category.create! valid_attributes
      get :edit, {id: category.to_param}
      expect(assigns(:category)).to eq(category)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Category" do
        expect do
          post :create, {category: valid_attributes}
        end.to change(Category, :count).by(1)
      end

      it "assigns a newly created category as @category" do
        post :create, {category: valid_attributes}
        expect(assigns(:category)).to be_a(Category)
        expect(assigns(:category)).to be_persisted
      end

      it "redirects to the created category" do
        post :create, {category: valid_attributes}
        expect(response).to redirect_to(convention_setup_categories_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved category as @category" do
        # Trigger the behavior that occurs when invalid params are submitted
        category = Category.create! valid_attributes
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        post :create, {category: {name: "Hi"}}
        expect(assigns(:category)).to be_a_new(Category)
        expect(assigns(:categories)).to eq([category])
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        post :create, {category: {name: "Hi"}}
        expect(response).to render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested category" do
        category = Category.create! valid_attributes
        # Assuming there are no other categories in the database, this
        # specifies that the Category created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Category).to receive(:update_attributes).with({})
        put :update, {id: category.to_param, category: {'these' => 'params'}}
      end

      it "assigns the requested category as @category" do
        category = Category.create! valid_attributes
        put :update, {id: category.to_param, category: valid_attributes}
        expect(assigns(:category)).to eq(category)
      end

      it "redirects to the category" do
        category = Category.create! valid_attributes
        put :update, {id: category.to_param, category: valid_attributes}
        expect(response).to redirect_to(convention_setup_categories_path)
      end
    end

    describe "with invalid params" do
      it "assigns the category as @category" do
        category = Category.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        put :update, {id: category.to_param, category: {name: 'fake'}}
        expect(assigns(:category)).to eq(category)
      end

      it "re-renders the 'edit' template" do
        category = Category.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Category).to receive(:save).and_return(false)
        put :update, {id: category.to_param, category: {name: "Hi"}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested category" do
      category = Category.create! valid_attributes
      expect do
        delete :destroy, {id: category.to_param}
      end.to change(Category, :count).by(-1)
    end

    it "redirects to the categories list" do
      category = Category.create! valid_attributes
      delete :destroy, {id: category.to_param}
      expect(response).to redirect_to(convention_setup_categories_url)
    end
  end
end
