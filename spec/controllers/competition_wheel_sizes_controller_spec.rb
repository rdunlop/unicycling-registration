require 'spec_helper'

describe CompetitionWheelSizesController do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:user) { FactoryGirl.create(:super_admin_user) }
  let(:registrant) { FactoryGirl.create(:competitor) }
  before { sign_in user }

  describe "GET index" do
    it "renders" do
      get :index, registrant_id: registrant.bib_number
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:valid_attributes) do
      {
        event_id: FactoryGirl.create(:event).id,
        wheel_size_id: WheelSize.first.id
      }
    end
    it "creates a competition_wheel_size" do
      expect do
        post :create, registrant_id: registrant.bib_number, competition_wheel_size: valid_attributes
      end.to change(CompetitionWheelSize, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    let!(:wheel_size) { FactoryGirl.create(:competition_wheel_size, registrant: registrant) }
    it "removes the result" do
      expect do
        delete :destroy, id: wheel_size.id, registrant_id: registrant.bib_number
      end.to change(CompetitionWheelSize, :count).by(-1)
    end
  end
end
