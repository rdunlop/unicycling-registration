require 'spec_helper'

describe ConventionSetup::PagesController do
  before(:each) do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end
  let(:page) { FactoryGirl.create(:page) }

  describe "GET index" do
    it "assigns all pages as @pages" do
      page
      get :index
      expect(assigns(:pages)).to eq([page])
    end
  end

  describe "GET new" do
    it "assigns a new page as @page" do
      get :new
      expect(assigns(:page)).to be_a_new(Page)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Page" do
        expect do
          post :create, page: FactoryGirl.attributes_for(:page)
        end.to change(Page, :count).by(1)
      end

      it "redirects to the created page" do
        post :create, page: FactoryGirl.attributes_for(:page)
        expect(response).to redirect_to(convention_setup_page_path(Page.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved page as @page" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Page).to receive(:save).and_return(false)
        post :create, page: { slug: "not valid" }
        expect(assigns(:page)).to be_a_new(Page)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Page).to receive(:save).and_return(false)
        post :create, page: { slug: "not valid" }
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET edit" do
    it "assigns the requested page as @page" do
      get :edit, id: page.to_param
      expect(assigns(:page)).to eq(page)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested page" do
        expect_any_instance_of(Page).to receive(:update_attributes).with({})
        put :update, id: page.to_param, page: {'these' => 'params'}
      end

      it "assigns the requested page as @page" do
        put :update, id: page.to_param, page: FactoryGirl.attributes_for(:page)
        expect(assigns(:page)).to eq(page)
      end

      it "redirects to the page" do
        # params = FactoryGirl.attributes_for(:page).merge(expense_item_attributes: { id: page.expense_item.id })
        put :update, id: page.to_param, page: FactoryGirl.attributes_for(:page)
        expect(response).to redirect_to(convention_setup_page_path(page))
      end
    end

    describe "with invalid params" do
      it "assigns the page as @page" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Page).to receive(:update_attributes).and_return(false)
        put :update, id: page.to_param, page: {slug: 'fake'}
        expect(assigns(:page)).to eq(page)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested page" do
      page
      expect do
        delete :destroy, id: page.to_param
      end.to change(Page, :count).by(-1)
    end

    it "redirects to the pages list" do
      delete :destroy, id: page.to_param
      expect(response).to redirect_to(convention_setup_pages_path)
    end
  end
end
