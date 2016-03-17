# == Schema Information
#
# Table name: tie_break_adjustments
#
#  id              :integer          not null, primary key
#  tie_break_place :integer
#  judge_id        :integer
#  competitor_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_tie_break_adjustments_competitor_id                  (competitor_id)
#  index_tie_break_adjustments_judge_id                       (judge_id)
#  index_tie_break_adjustments_on_competitor_id               (competitor_id) UNIQUE
#  index_tie_break_adjustments_on_competitor_id_and_judge_id  (competitor_id,judge_id) UNIQUE
#

require 'spec_helper'

describe TieBreakAdjustmentsController do
  before(:each) do
    @user = FactoryGirl.create(:data_entry_volunteer_user)

    @judge = FactoryGirl.create(:judge, user_id: @user.id)
    @jt = FactoryGirl.create(:judge_type)

    @competitor = FactoryGirl.create(:event_competitor, competition: @judge.competition)

    sign_in @user
  end

  describe "GET index" do
    it "assigns all tie_break_adjustments as @tie_break_adjustments" do
      tie_break_adjustment = FactoryGirl.create(:tie_break_adjustment, competitor: @competitor, judge: @judge)
      get :index, judge_id: @judge.id
      expect(assigns(:tie_break_adjustments)).to eq([tie_break_adjustment])
    end
    it "assigns a new tie_break_adjustment" do
      get :index, judge_id: @judge.id
      expect(assigns(:tie_break_adjustment)).to be_a_new(TieBreakAdjustment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:valid_attributes) do
        {
          tie_break_place: "1",
          competitor_id: @competitor.id,
          judge_id: @judge.id
        }
      end

      it "creates a new TimeResult" do
        expect do
          post :create, judge_id: @judge.id, tie_break_adjustment: valid_attributes
        end.to change(TieBreakAdjustment, :count).by(1)
      end

      it "redirects to the index" do
        post :create, judge_id: @judge.id, tie_break_adjustment: valid_attributes
        expect(response).to redirect_to(judge_tie_break_adjustments_path(@judge))
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested tie_break_adjustment" do
      tie_break_adjustment = FactoryGirl.create(:tie_break_adjustment, judge: @judge)
      expect do
        delete :destroy, id: tie_break_adjustment.to_param
      end.to change(TieBreakAdjustment, :count).by(-1)
    end

    it "redirects to the event's tie_break_adjustment list" do
      tie_break_adjustment = FactoryGirl.create(:tie_break_adjustment, judge: @judge)
      delete :destroy, id: tie_break_adjustment.to_param
      expect(response).to redirect_to(judge_tie_break_adjustments_path(@judge))
    end
  end
end
