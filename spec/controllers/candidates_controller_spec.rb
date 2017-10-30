require 'spec_helper'

describe CandidatesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
  end
  let(:competition) { FactoryGirl.create(:competition) }
  let(:reg) { FactoryGirl.create(:competitor) }

  describe "GET index" do
    let(:params) do
      {
        competition_id: competition.id
      }
    end
    it "renders" do
      get :index, params: params
      expect(response).to be_success
    end
  end

  describe "POST create_from_candidates" do
    let(:params) do
      {
        competition_id: competition.id,
        heat: 1,
        competitors: {
          "1" => {
            bib_number: reg.bib_number,
            lane: 1
          }
        }
      }
    end
    it "creates a competitor" do
      post :create_from_candidates, params: params
      expect(Competitor.count).to eq(1)
    end
  end
end
