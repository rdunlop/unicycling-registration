require 'spec_helper'

describe ScoresController do
  before (:each) do
    @admin = FactoryGirl.create(:admin_user)
    @user = FactoryGirl.create(:data_entry_volunteer_user)
    @other_user = FactoryGirl.create(:data_entry_volunteer_user)
    sign_in @admin

    @judge = FactoryGirl.create(:judge, :user_id => @user.id)
    @jt = FactoryGirl.create(:judge_type)
    @judge_with_pres = FactoryGirl.create(:judge, :judge_type => @jt, :user_id => @other_user.id)
    @other_judge = FactoryGirl.create(:judge, :user_id => @other_user.id)

    @comp = FactoryGirl.create(:event_competitor, :competition => @judge.competition)
    @comp2 = FactoryGirl.create(:event_competitor, :competition => @judge.competition)
    @judge.competition.competitors << @comp2
    @judge.competition.competitors << @comp
    @judge.save!

    @signed_in_scores = [
      FactoryGirl.create(:score, :judge => @judge, :competitor => @comp),
      FactoryGirl.create(:score, :judge => @judge, :competitor => @comp2)]
    sign_out @admin

    # create a chief_judge, so that this lowly judge-user can see the scores page
    # FactoryGirl.create(:chief_judge, :event => @judge.event_category.event, :user => @user)
    # XXX
    @user.add_role :admin

    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # Score. As you add validations to Score, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { :val_1 => 1.1,
      :val_2 => 2.2,
      :val_3 => 3.3,
      :val_4 => 4.4,
      :notes => "hi"
    }
  end

  describe "GET new" do
    it "assigns the requested score as @score" do
      score = @signed_in_scores[0]
      get :new, {:judge_id => @judge.id, :competitor_id => @comp.id}
      expect(assigns(:score)).to eq(score)
    end
  end

  describe "POST create" do
    before(:each) do
      sign_out @user
      sign_in @other_user
    end
    describe "with valid params" do
      it "creates a new Score" do
        expect {
          post :create, {:score => valid_attributes, :judge_id => @other_judge.id, :competitor_id => @comp.id}
        }.to change(Score, :count).by(1)
      end
    end
  end

  describe "when the event is locked" do
    before(:each) do
      @comp.competition.locked = true
      @comp.competition.save!
    end
    it "should not be allowed to create scores" do
      expect {
        post :create, {:score => valid_attributes, :judge_id => @other_judge.id, :competitor_id => @comp.id}
      }.to change(Score, :count).by(0)
    end
  end

  describe "POST create On an existing score" do
    describe "with valid params" do
      it "updates the requested score" do
        score = @signed_in_scores[0]
        # Assuming there are no other scores in the database, this
        # specifies that the Score created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Score).to receive(:assign_attributes).with({'val_1' => '2.1'})
        post :create, {:score => {:val_1 => '2.1'}, :judge_id => @judge, :competitor_id => @comp.id}
      end

      it "assigns the requested score as @score" do
        score = @signed_in_scores[0]
        post :create, {:score => valid_attributes, :judge_id => @judge, :competitor_id => @comp.id}
        expect(assigns(:score)).to eq(score)
      end

      it "redirects to the score" do
        score = @signed_in_scores[0]
        post :create, {:score => valid_attributes, :judge_id => @judge, :competitor_id => @comp.id}
        expect(response).to redirect_to(judge_scores_url(@judge))
      end
    end

    describe "with invalid params" do
      it "assigns the score as @score" do
        score = @signed_in_scores[0]
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Score).to receive(:save).and_return(false)
        post :create, {:score => {:number_of_people => 1}, :judge_id => @judge, :competitor_id => @comp.id}
        expect(assigns(:score)).to eq(score)
      end

      it "re-renders the 'new' template" do
        score = @signed_in_scores[0]
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Score).to receive(:save).and_return(false)
        post :create, {:score => {:val_1 => 1}, :judge_id => @judge.id, :competitor_id => @comp.id}
        expect(response).to render_template("new")
      end
    end

    describe "authentication of edit/update pages" do
      # http://ruby.railstutorial.org/chapters/updating-showing-and-deleting-users#sec:protecting_pages

      before (:each) do
        # create score with existing current_user
        @user_score = @signed_in_scores[0]

        # Change logged-in user
        sign_out @user
        @auth_user = FactoryGirl.create(:user)
        sign_in @auth_user
      end
      it "should deny access to edit" do
        get :new, {:judge_id => @judge, :competitor_id => @comp.id}
        expect(response).to redirect_to(root_path)
      end
      it "should deny access to update" do
        post :create, {:judge_id => @judge, :competitor_id => @comp.id}
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
