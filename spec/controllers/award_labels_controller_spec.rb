# == Schema Information
#
# Table name: award_labels
#
#  id            :integer          not null, primary key
#  bib_number    :integer
#  line_2        :string(255)
#  line_3        :string(255)
#  line_5        :string(255)
#  place         :integer
#  user_id       :integer
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  line_1        :string(255)
#  line_4        :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

require 'spec_helper'

describe AwardLabelsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:award_admin_user)
    sign_in @admin_user
    @registrant = FactoryGirl.create(:competitor)
  end
  let (:award_label) { FactoryGirl.create(:award_label, user: @admin_user) }

  # This should return the minimal set of attributes required to create a valid
  # AwardLabel. As you add validations to AwardLabel, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "registrant_id" => @registrant.id,
      "place" => 1
    }
  end

  describe "GET index" do
    describe "When not signed in" do
      before { sign_out @admin_user }
      it "redirects to root path" do
        get :index, user_id: @admin_user
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    it "assigns all award_labels as @award_labels" do
      aw_label = FactoryGirl.create(:award_label, user: @admin_user)
      get :index, user_id: @admin_user
      expect(assigns(:award_labels)).to eq([aw_label])
    end
  end

  describe "GET edit" do
    it "assigns the requested award_label as @award_label" do
      get :edit, id: award_label.to_param
      expect(assigns(:award_label)).to eq(award_label)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AwardLabel" do
        expect do
          post :create, award_label: valid_attributes, user_id: @admin_user.id
        end.to change(AwardLabel, :count).by(1)
      end

      it "assigns a newly created award_label as @award_label" do
        post :create, award_label: valid_attributes, user_id: @admin_user.id
        expect(assigns(:award_label)).to be_a(AwardLabel)
        expect(assigns(:award_label)).to be_persisted
      end

      it "redirects to the created award_label" do
        post :create, award_label: valid_attributes, user_id: @admin_user.id
        expect(response).to redirect_to(user_award_labels_path(@admin_user))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved award_label as @award_label" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AwardLabel).to receive(:save).and_return(false)
        post :create, award_label: { "bib_number" => "invalid value" }, user_id: @admin_user.id
        expect(assigns(:award_label)).to be_a_new(AwardLabel)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AwardLabel).to receive(:save).and_return(false)
        post :create, award_label: { "bib_number" => "invalid value" }, user_id: @admin_user.id
        expect(response).to render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested award_label" do
        # Assuming there are no other award_labels in the database, this
        # specifies that the AwardLabel created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(AwardLabel).to receive(:update_attributes).with("bib_number" => "1")
        put :update, id: award_label.to_param, award_label: { "bib_number" => "1" }
      end

      it "assigns the requested award_label as @award_label" do
        put :update, id: award_label.to_param, award_label: valid_attributes
        expect(assigns(:award_label)).to eq(award_label)
      end

      it "redirects to the award_label" do
        put :update, id: award_label.to_param, award_label: valid_attributes
        expect(response).to redirect_to(user_award_labels_path(@admin_user))
      end
    end

    describe "with invalid params" do
      it "assigns the award_label as @award_label" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AwardLabel).to receive(:save).and_return(false)
        put :update, id: award_label.to_param, award_label: { "bib_number" => "invalid value" }
        expect(assigns(:award_label)).to eq(award_label)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AwardLabel).to receive(:save).and_return(false)
        put :update, id: award_label.to_param, award_label: { "bib_number" => "invalid value" }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested award_label" do
      aw_label = FactoryGirl.create(:award_label, user: @admin_user)
      expect do
        delete :destroy, id: aw_label.to_param
      end.to change(AwardLabel, :count).by(-1)
    end

    it "redirects to the award_labels list" do
      delete :destroy, id: award_label.to_param
      expect(response).to redirect_to(user_award_labels_path(@admin_user))
    end
  end

  describe "with competition and competitors" do
    let!(:competition) { FactoryGirl.create(:competition) }
    let!(:competitors) { FactoryGirl.create_list(:event_competitor, 5, competition: competition) }
    before do
      competitors.each do |competitor|
        FactoryGirl.create(:result, :overall, competitor: competitor)
      end
    end

    describe "POST create_by_competition" do
      it "renders" do
        expect do
          post :create_by_competition, competition_id: competition.id, user_id: @admin_user.to_param
        end.to change(AwardLabel, :count).by(5)
      end
    end

    describe "POST create_labels" do
      context "by registrant_id" do
      end

      context "by registrant_group_id"

      context "by competition id" do
        it "renders" do
          expect do
            post :create_labels, age_groups: "true", competition_id: competition.id, user_id: @admin_user.to_param
          end.to change(AwardLabel, :count).by(5)
          expect(response).to redirect_to(user_award_labels_path(@admin_user))
        end
      end
    end

    describe "DELETE destroy_all" do
      let!(:award) { FactoryGirl.create(:award_label, user: @admin_user) }

      it "removes award" do
        expect do
          delete :destroy_all, user_id: @admin_user.to_param
        end.to change(AwardLabel, :count).by(-1)
      end
    end

    describe "GET normal_labels" do
      it "renders" do
        get :normal_labels, user_id: @admin_user.to_param
        expect(response).to be_success
      end
    end

    describe "GET announcer_sheet" do
      it "renders" do
        get :normal_labels, user_id: @admin_user.to_param
        expect(response).to be_success
      end
    end
  end
end
