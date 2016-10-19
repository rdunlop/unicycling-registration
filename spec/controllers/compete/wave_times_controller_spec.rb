require 'spec_helper'

describe Compete::WaveTimesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end
  let(:competition) { FactoryGirl.create(:competition) }
  let(:wave_time) { FactoryGirl.create(:wave_time, competition: competition) }

  describe "GET index" do
    it "renders" do
      get :index, params: { competition_id: competition.id }
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:attributes) { FactoryGirl.attributes_for(:wave_time) }

    it "creates a new wave time" do
      expect do
        post :create, params: { competition_id: competition.id, wave_time: attributes }
      end.to change(WaveTime, :count).by(1)
    end
  end

  describe "GET edit" do
    it "renders" do
      get :edit, params: { id: wave_time.id, competition_id: competition.id }
      expect(response).to be_success
    end
  end

  describe "PUT update" do
    it "updates wave time" do
      put :update, params: { competition_id: competition.id, id: wave_time.id, wave_time: { minutes: "10" } }
      expect(wave_time.reload.minutes).to eq(10)
    end
  end

  describe "DELETE destroy" do
    it "removes" do
      wave_time
      expect do
        delete :destroy, params: { competition_id: competition.id, id: wave_time.id }
      end.to change(WaveTime, :count).by(-1)
    end
  end
end
