require 'spec_helper'

describe ConventionSetup::PagesController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end
  let(:page) { FactoryGirl.create(:page) }

  describe "GET index" do
    it "shows all pages" do
      page
      get :index

      assert_select "h1", "Information Pages"
      assert_select "td", page.slug
    end
  end

  describe "GET new" do
    it "shows a new page" do
      get :new
      assert_select "h1", "New Information Page"
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Page" do
        expect do
          post :create, params: { page: FactoryGirl.attributes_for(:page) }
        end.to change(Page, :count).by(1)
      end

      it "redirects to the created page" do
        post :create, params: { page: FactoryGirl.attributes_for(:page) }
        expect(response).to redirect_to(convention_setup_page_path(Page.last))
      end
    end

    describe "with invalid params" do
      it "does not create a new page" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Page).to receive(:save).and_return(false)
        expect do
          post :create, params: { page: { slug: "not valid" } }
        end.not_to change(Page, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Page).to receive(:save).and_return(false)
        post :create, params: { page: { slug: "not valid" } }

        assert_select "h1", "New Information Page"
      end
    end
  end

  describe "GET edit" do
    it "shows the requested page form" do
      get :edit, params: { id: page.to_param }

      assert_select "h1", "Edit Information Page"
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the page" do
        expect do
          put :update, params: { id: page.to_param, page: FactoryGirl.attributes_for(:page) }
        end.to change { page.reload.slug }
      end

      it "redirects to the page" do
        # params = FactoryGirl.attributes_for(:page).merge(expense_item_attributes: { id: page.expense_item.id })
        put :update, params: { id: page.to_param, page: FactoryGirl.attributes_for(:page) }
        expect(response).to redirect_to(convention_setup_page_path(page))
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested page" do
      page
      expect do
        delete :destroy, params: { id: page.to_param }
      end.to change(Page, :count).by(-1)
    end

    it "redirects to the pages list" do
      delete :destroy, params: { id: page.to_param }
      expect(response).to redirect_to(convention_setup_pages_path)
    end
  end
end
