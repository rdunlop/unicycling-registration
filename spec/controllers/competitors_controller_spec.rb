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
    it "assigns all competitors as @competitors" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      get :index, competition_id: @ec.id
      expect(assigns(:competitors)).to eq([competitor])
    end
  end

  describe "GET edit" do
    it "assigns the requested competitor as @competitor" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      get :edit, id: competitor.to_param
      expect(assigns(:competitor)).to eq(competitor)
    end
  end
  describe "GET new" do
    it "assigns a new competitor as @competitor" do
      get :new, competition_id: @ec.to_param
      expect(assigns(:competitor)).to be_a_new(Competitor)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Competitor" do
        expect do
          post :create, competitor: valid_attributes, competition_id: @ec.id
        end.to change(Competitor, :count).by(1)
      end

      it "assigns a newly created competitor as @competitor" do
        post :create, competitor: valid_attributes, competition_id: @ec.id
        expect(assigns(:competitor)).to be_a(Competitor)
        expect(assigns(:competitor)).to be_persisted
      end

      it "creates associated members also" do
        @reg2 = FactoryGirl.create(:competitor) # registrant
        @reg3 = FactoryGirl.create(:competitor) # registrant
        expect do
          post :create, competitor: valid_attributes.merge(
            members_attributes:               { "0" => {registrant_id: @reg2.id},
                                                "1" => {registrant_id: @reg3.id}
              }), competition_id: @ec.id
        end.to change(Member, :count).by(2)
      end

      it "redirects back to index" do
        post :create, competitor: valid_attributes, competition_id: @ec.id
        expect(response).to redirect_to(competition_competitors_path(@ec))
      end
      it "can create with custom external id and name" do
        reg1 = FactoryGirl.create(:competitor)
        reg2 = FactoryGirl.create(:competitor)
        reg3 = FactoryGirl.create(:competitor)
        expect do
          post :create, competitor: valid_attributes.merge(
            members_attributes:
              { "0" => {registrant_id: reg1.id},
                "1" => {registrant_id: reg2.id},
                "2" => {registrant_id: reg3.id}
              }, custom_name: 'Robin Rocks!'), competition_id: @ec.id
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
          post :add_all, competition_id: @ec.id
        end.to change(Competitor, :count).by(2)
      end
      it "should not create any new competitors if we run it twice" do
        post :add_all, competition_id: @ec.id

        expect do
          post :add_all, competition_id: @ec.id
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
            post :add_all, competition_id: @ec.id
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
          delete :destroy_all, competition_id: @ec.to_param
        end.to change(Competitor, :count).by(-3)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved competitor as @competitor" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:save).and_return(false)
        post :create, competitor: {custom_name: "name"}, competition_id: @ec.id
        expect(assigns(:competitor)).to be_a_new(Competitor)
      end

      it "re-renders the 'competitors#new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:valid?).and_return(false)
        allow_any_instance_of(Competitor).to receive(:errors).and_return("anything")
        post :create, competitor: {custom_name: "name"}, competition_id: @ec.id
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested competitor" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        # Assuming there are no other competitor in the database, this
        # specifies that the Competitor created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Competitor).to receive(:update_attributes).with({})
        put :update, id: competitor.to_param, competitor: {'these' => 'params'}
      end

      it "assigns the requested competitor as @competitor" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        put :update, id: competitor.to_param, competitor: valid_attributes
        expect(assigns(:competitor)).to eq(competitor)
      end

      it "redirects to the competition" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        put :update, id: competitor.to_param, competitor: valid_attributes
        expect(response).to redirect_to(competition_competitors_path(competitor.competition))
      end
    end

    describe "with invalid params" do
      it "assigns the competitor as @competitor" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:valid?).and_return(false)
        allow_any_instance_of(Competitor).to receive(:errors).and_return("anything")
        put :update, id: competitor.to_param, competitor: {custom_name: "name"}
        expect(assigns(:competitor)).to eq(competitor)
      end

      it "re-renders the 'events#edit' template" do
        competitor = FactoryGirl.create(:event_competitor, competition: @ec)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Competitor).to receive(:valid?).and_return(false)
        allow_any_instance_of(Competitor).to receive(:errors).and_return("anything")
        put :update, id: competitor.to_param, competitor: {custom_name: "name"}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested competitor" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      expect do
        delete :destroy, id: competitor.to_param
      end.to change(Competitor, :count).by(-1)
    end

    it "redirects to the competitor#new page" do
      competitor = FactoryGirl.create(:event_competitor, competition: @ec)
      delete :destroy, id: competitor.to_param
      expect(response).to redirect_to(competition_competitors_path(@ec))
    end
  end
end
