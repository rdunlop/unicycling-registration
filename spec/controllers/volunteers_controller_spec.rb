# == Schema Information
#
# Table name: competitors
#
#  id                       :integer          not null, primary key
#  competition_id           :integer
#  position                 :integer
#  custom_name              :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  status                   :integer          default(0)
#  lowest_member_bib_number :integer
#  geared                   :boolean          default(FALSE), not null
#  riding_wheel_size        :integer
#  notes                    :string(255)
#  wave                     :integer
#  riding_crank_size        :integer
#
# Indexes
#
#  index_competitors_event_category_id  (competition_id)
#

require 'spec_helper'

describe VolunteersController do
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:timed_competition, event: @ev)

    @ec.save!
    user.add_role :director, @ev
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Competitor. As you add validations to Competitor, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { notes: "hello" }
  end

  describe "GET index" do
    it "renders the page" do
      get :index, competition_id: @ec.id
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let!(:other_user) { FactoryGirl.create(:user) }
    before { request.env["HTTP_REFERER"] = competition_path(@ec) }
    describe "with valid params" do
      it "creates a new Volunteer" do
        expect do
          post :create, params: { competition_id: @ec.id, user_id: other_user.id, volunteer_type: "race_official" }
        end.to change(other_user.roles, :count).by(1)
      end
    end

    describe "with missing user_id" do
      it "returns the user to the competition page" do
        post :create, params: { competition_id: @ec.id, volunteer_type: "race_official" }
        expect(response).to redirect_to(competition_path(@ec))
      end
    end

    describe "with invalid volunteer_type" do
      it "does something" do
        expect do
          post :create, params: { competition_id: @ec.id, user_id: other_user.id, volunteer_type: "big_boss" }
        end.not_to change(other_user.roles, :count)
        expect(response).to redirect_to(competition_path(@ec))
      end
    end
  end

  describe "DELETE destroy" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      other_user.add_role(:race_official, @ec)
    end

    it "removes the role" do
      expect do
        delete :destroy, params: { competition_id: @ec.id, user_id: other_user.id, volunteer_type: "race_official" }
      end.to change(other_user.roles, :count).by(-1)
    end
  end
end
