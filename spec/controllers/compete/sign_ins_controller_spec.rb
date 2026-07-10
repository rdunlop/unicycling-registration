require 'spec_helper'

describe Compete::SignInsController do
  before do
    sign_in FactoryBot.create(:super_admin_user)
  end

  let(:competition) { FactoryBot.create(:timed_competition, start_data_type: "Mass Start") }

  let(:valid_attributes) { { "name" => "MyString" } }

  describe "GET show" do
    it "displays the competitors" do
      get :show, params: { competition_id: competition.id }
      expect(response).to be_successful
    end

    it "downloads the pdf" do
      get :show, params: { competition_id: competition.id, format: :pdf }
      expect(response.content_type.to_s).to eq("application/pdf")
    end
  end

  describe "GET edit" do
    it "displays the competitors" do
      get :edit, params: { competition_id: competition.id }
      expect(response).to be_successful
    end
  end

  describe "PUT update" do
    before { request.env["HTTP_REFERER"] = competition_path(competition) }

    let!(:competitor1) { FactoryBot.create(:event_competitor, competition: competition, bib_number: 101) }

    it "updates the sign_ins with wave" do
      params = {
        competitors_attributes: {
          "0" => {
            wave: 1,
            id: competitor1.id
          }
        }
      }
      expect(competitor1.wave).to be_nil
      put :update, params: { competition_id: competition.id, competition: params }
      expect(competitor1.reload.wave).to eq(1)
    end

    it "updates the sign_ins with minimum wheel size" do
      params = {
        competitors_attributes: {
          "0" => {
            id: competitor1.id,
            riding_wheel_size: 8
          }
        }
      }
      expect(competitor1.riding_wheel_size).to be_nil
      put :update, params: { competition_id: competition.id, competition: params }
      expect(competitor1.reload.riding_wheel_size).to eq(8)
    end

    it "updates the sign_ins with maximum wheel size" do
      params = {
        competitors_attributes: {
          "0" => {
            id: competitor1.id,
            riding_wheel_size: 99.99
          }
        }
      }
      expect(competitor1.riding_wheel_size).to be_nil
      put :update, params: { competition_id: competition.id, competition: params }
      expect(competitor1.reload.riding_wheel_size).to eq(99.99)
    end

    it "updates the sign_ins with float wheel size" do
      params = {
        competitors_attributes: {
          "0" => {
            id: competitor1.id,
            riding_wheel_size: 27.5
          }
        }
      }
      expect(competitor1.riding_wheel_size).to be_nil
      put :update, params: { competition_id: competition.id, competition: params }
      expect(competitor1.reload.riding_wheel_size).to eq(27.5)
    end

    it "fails to update the sign_ins with too small wheel size" do
      params = {
        competitors_attributes: {
          "0" => {
            id: competitor1.id,
            riding_wheel_size: 7
          }
        }
      }
      expect(competitor1.riding_wheel_size).to be_nil
      put :update, params: { competition_id: competition.id, competition: params }
      expect(competitor1.reload.riding_wheel_size).to be_nil
    end

    it "fails to update the sign_ins with too big wheel size" do
      params = {
        competitors_attributes: {
          "0" => {
            id: competitor1.id,
            riding_wheel_size: 101
          }
        }
      }
      expect(competitor1.riding_wheel_size).to be_nil
      put :update, params: { competition_id: competition.id, competition: params }
      expect(competitor1.reload.riding_wheel_size).to be_nil
    end
  end
end
