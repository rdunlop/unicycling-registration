require 'spec_helper'

describe ConventionSetup::ConventionSeriesController do
  before do
    user = FactoryBot.create(:super_admin_user)
    sign_in user
  end

  describe "GET index" do
    let!(:series) { FactoryBot.create(:convention_series) }

    it "displays all" do
      get :index
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:params) { FactoryBot.attributes_for(:convention_series) }

    it "creates a new series" do
      expect do
        post :create, params: { convention_series: params }
      end.to change(ConventionSeries, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    let!(:series) { FactoryBot.create(:convention_series) }

    it "deletes a new series" do
      expect do
        delete :destroy, params: { id: series.id }
      end.to change(ConventionSeries, :count).by(-1)
    end
  end

  describe "GET show" do
    let(:series) { FactoryBot.create(:convention_series) }

    it "displays the series" do
      get :show, params: { id: series.id }
      expect(response).to be_success
    end
  end

  context "with a series" do
    let(:series) { FactoryBot.create(:convention_series) }

    describe "POST add" do
      it "adds tenant to series" do
        expect do
          post :add, params: { id: series.id }
        end.to change(ConventionSeriesMember, :count).by(1)
      end
    end

    describe "DELETE remove" do
      let!(:member) { FactoryBot.create(:convention_series_member, convention_series: series, tenant: Tenant.first) }

      it "removes tenant from series" do
        expect do
          delete :remove, params: { id: series.id }
        end.to change(ConventionSeriesMember, :count).by(-1)
      end
    end
  end
end
