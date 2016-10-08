require 'spec_helper'

describe Compete::SignInsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
  end

  let(:competition) { FactoryGirl.create(:timed_competition, start_data_type: "Mass Start") }

  let(:valid_attributes) { { "name" => "MyString" } }

  describe "GET show" do
    it "displays the competitors" do
      get :show, params: { competition_id: competition.id }
      expect(response).to be_success
    end

    it "downloads the pdf" do
      get :show, params: { competition_id: competition.id, format: :pdf }
      expect(response.content_type.to_s).to eq("application/pdf")
    end
  end

  describe "GET edit" do
    it "displays the competitors" do
      get :edit, params: { competition_id: competition.id }
      expect(response).to be_success
    end
  end

  describe "PUT update" do
    before { request.env["HTTP_REFERER"] = competition_path(competition) }
    let!(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 101) }

    it "updates the sign_ins" do
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
  end
end
