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
#  status                   :integer          default("active")
#  lowest_member_bib_number :integer
#  geared                   :boolean          default(FALSE), not null
#  riding_wheel_size        :integer
#  notes                    :string(255)
#  wave                     :integer
#  riding_crank_size        :integer
#  withdrawn_at             :datetime
#  tier_number              :integer          default(1), not null
#  tier_description         :string
#  age_group_entry_id       :integer
#
# Indexes
#
#  index_competitors_event_category_id                         (competition_id)
#  index_competitors_on_competition_id_and_age_group_entry_id  (competition_id,age_group_entry_id)
#

require 'spec_helper'

describe CompetitorsController do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = FactoryGirl.create(:competition, event: @ev)
    @ec.save!
    sign_in FactoryGirl.create(:competition_admin_user)
  end

  # This should return the minimal set of attributes required to create a valid
  # Competitor. As you add validations to Competitor, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { notes: "hello" }
  end

  describe "GET index" do
    it "shows all competitors" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      get :index, params: { competition_id: @ec.id }
      assert_select "h3", "Competitors"
      assert_select "td", competitor.bib_number
    end
  end

  describe "GET edit" do
    it "shows the requested competitor" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      get :edit, params: { id: competitor.to_param }

      assert_select "form", action: new_competition_competitor_path(@ec), method: "post" do
        assert_select "input#competitor_custom_name", name: "competitor[custom_name]"
      end
    end
  end

  describe "GET new" do
    it "shows a new competitor form" do
      get :new, params: { competition_id: @ec.to_param }

      assert_select "form", action: new_competition_competitor_path(@ec), method: "post" do
        assert_select "input#competitor_custom_name", name: "competitor[custom_name]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Competitor" do
        expect do
          post :create, params: { competitor: valid_attributes, competition_id: @ec.id }
        end.to change(Competitor, :count).by(1)
      end

      it "creates associated members also" do
        @reg2 = FactoryGirl.create(:competitor) # registrant
        @reg3 = FactoryGirl.create(:competitor) # registrant
        expect do
          post :create, params: { competitor: valid_attributes.merge(
            members_attributes:               { "0" => {registrant_id: @reg2.id},
                                                "1" => {registrant_id: @reg3.id}}
          ), competition_id: @ec.id }
        end.to change(Member, :count).by(2)
      end

      it "redirects back to index" do
        post :create, params: { competitor: valid_attributes, competition_id: @ec.id }
        expect(response).to redirect_to(competition_competitors_path(@ec))
      end
      it "can create with custom external id and name" do
        reg1 = FactoryGirl.create(:competitor)
        reg2 = FactoryGirl.create(:competitor)
        reg3 = FactoryGirl.create(:competitor)
        expect do
          post :create, params: { competitor: valid_attributes.merge(
            members_attributes:
              { "0" => {registrant_id: reg1.id},
                "1" => {registrant_id: reg2.id},
                "2" => {registrant_id: reg3.id}}, custom_name: 'Robin Rocks!'
          ), competition_id: @ec.id }
        end.to change(Competitor, :count).by(1)
      end
    end

    describe "add_all adds all registrants" do
      before(:each) do
        FactoryGirl.create(:registrant, bib_number: 1)
        FactoryGirl.create(:registrant, bib_number: 2)
        FactoryGirl.create(:noncompetitor, bib_number: 3)
      end
      it "should create a competitor for every registrant" do
        expect do
          post :add_all, params: { competition_id: @ec.id }
        end.to change(Competitor, :count).by(2)
      end
      it "should not create any new competitors if we run it twice" do
        post :add_all, params: { competition_id: @ec.id }

        expect do
          post :add_all, params: { competition_id: @ec.id }
        end.to change(Competitor, :count).by(0)
      end

      describe "when adding multiple non-contiguous external_id registrants" do
        it "should add them with continuous position numbers" do
          FactoryGirl.create(:registrant, bib_number: 9)
          FactoryGirl.create(:registrant, bib_number: 8)
          FactoryGirl.create(:registrant, bib_number: 7)
          FactoryGirl.create(:registrant, bib_number: 6)
          FactoryGirl.create(:registrant, bib_number: 5)
          expect do
            post :add_all, params: { competition_id: @ec.id }
          end.to change(Competitor, :count).by(7)

          @ec.competitors.each_with_index do |c, i|
            expect(c.position).to eq(i + 1)
          end
        end
      end
    end
    describe "with the 'destroy_all' field" do
      before(:each) do
        FactoryGirl.create(:event_competitor, competition: @ec)
        FactoryGirl.create(:event_competitor, competition: @ec)
        FactoryGirl.create(:event_competitor, competition: @ec)
      end
      it "should remove all competitors in this event" do
        expect do
          delete :destroy_all, params: { competition_id: @ec.to_param }
        end.to change(Competitor, :count).by(-3)
      end
    end

    describe "with invalid params" do
      it "re-renders the 'competitors#new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:valid?).and_return(false)
        post :create, params: { competitor: {custom_name: "name"}, competition_id: @ec.id }
        assert_select "h4", "Add New Competitor"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested competitor" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        expect do
          put :update, params: { id: competitor.to_param, competitor: valid_attributes.merge(status: "withdrawn") }
        end.to change{ competitor.reload.status }
      end

      it "redirects to the competition" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        put :update, params: { id: competitor.to_param, competitor: valid_attributes }
        expect(response).to redirect_to(competition_competitors_path(competitor.competition))
      end
    end

    describe "with invalid params" do
      it "does not change the competitor" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:valid?).and_return(false)
        expect do
          put :update, params: { id: competitor.to_param, competitor: {custom_name: "name"} }
        end.not_to change{ competitor.reload.custom_name }
      end

      it "re-renders the 'events#edit' template" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:valid?).and_return(false)
        put :update, params: { id: competitor.to_param, competitor: {custom_name: "name"} }
        assert_select "h1", "Editing competitor"
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested competitor" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      expect do
        delete :destroy, params: { id: competitor.to_param }
      end.to change(Competitor, :count).by(-1)
    end

    it "redirects to the competitor#new page" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      delete :destroy, params: { id: competitor.to_param }
      expect(response).to redirect_to(competition_competitors_path(@ec))
    end
  end
end
