# == Schema Information
#
# Table name: results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  result_type    :string(255)
#  result_subtype :integer
#  place          :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_results_on_competitor_id_and_result_type  (competitor_id,result_type) UNIQUE
#

require 'spec_helper'

describe ResultsController do
  before(:each) do
    @user = FactoryGirl.create(:super_admin_user)
    sign_in @user
  end
  let(:registrant) { FactoryGirl.create(:competitor) }
  let(:competition) { FactoryGirl.create(:competition) }

  describe "GET index" do
    it "renders" do
      get :index
      expect(response).to be_success
    end
  end

  describe "GET registrant" do
    it "renders" do
      get :registrant, params: { registrant_id: registrant.id }
      expect(response).to redirect_to(results_registrant_path(registrant))
    end
  end

  describe "GET scores" do
    let(:competition) { FactoryGirl.create(:competition, :combined) }
    it "renders" do
      get :scores, params: { id: competition.id }
      expect(response).to be_success
    end
  end
end
